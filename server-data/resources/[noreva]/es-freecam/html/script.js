$(function () {
    const resourceName = (typeof GetParentResourceName === 'function')
        ? GetParentResourceName()
        : 'es-freecam';

    let currentFilter = 'normal';
    let filterList = {};
    let filterOrder = [];
    let pendingDeleteId = null;
    let ignoreSync = false;
    let freecamActive = false;
    let strengthTimer = null;
    let pendingStrength = null;
    let cinematicState = { enabled: false, letterboxSize: 0.12 };

    let overlayState = {
        grid: false,
        hudInfo: true,
        lookAtPed: false,
        smoothCam: true
    };
    let themes = {};
    let i18n = {};

    function t(key, fallback) {
        if (i18n && i18n[key]) return i18n[key];
        return fallback || key;
    }

    function applyI18n(strings) {
        if (!strings || typeof strings !== 'object') return;
        i18n = strings;
        $('[data-i18n]').each(function () {
            const key = $(this).attr('data-i18n');
            if (i18n[key]) $(this).text(i18n[key]);
        });
        $('[data-i18n-placeholder]').each(function () {
            const key = $(this).attr('data-i18n-placeholder');
            if (i18n[key]) $(this).attr('placeholder', i18n[key]);
        });
        $('[data-i18n-title]').each(function () {
            const key = $(this).attr('data-i18n-title');
            if (i18n[key]) $(this).attr('title', i18n[key]);
        });
        document.documentElement.lang = (strings._lang || 'en');
    }

    function nuiPost(endpoint, data) {
        return fetch(`https://${resourceName}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data || {})
        });
    }

    function isHelpVisible() {
        return !$('#help-menu').hasClass('hidden');
    }

    function isModalOpen() {
        return !$('#save-position-modal').hasClass('hidden')
            || !$('#delete-confirm-modal').hasClass('hidden');
    }

    function syncFocus(force) {
        if (typeof force === 'boolean') {
            nuiPost('setNuiFocus', { focus: force, helpOpen: isHelpVisible() });
            return;
        }
        const need = isHelpVisible() || isModalOpen();
        nuiPost('setNuiFocus', { focus: need, helpOpen: isHelpVisible() });
    }

    function applyTheme(name) {
        if (!name) return;
        $('body').attr('data-theme', name);
        $('.theme-swatch').removeClass('active');
        $(`.theme-swatch[data-theme="${name}"]`).addClass('active');

        const theme = themes[name];
        if (!theme) return;
        const root = document.documentElement.style;
        root.setProperty('--bg', theme.background);
        root.setProperty('--text', theme.text);
        root.setProperty('--accent', theme.accent);
        root.setProperty('--border', theme.border);
    }

    function syncCinematicOverlay() {
        const sizePct = Math.max(4, Math.min(25, (cinematicState.letterboxSize || 0.12) * 100));
        document.documentElement.style.setProperty('--letterbox-size', sizePct + 'vh');
        const $overlay = $('#cinematic-overlay');
        if (cinematicState.enabled && freecamActive) {
            // reflow sonra active — soft giriş
            $overlay.removeClass('hidden');
            requestAnimationFrame(function () {
                $overlay.addClass('active');
            });
        } else {
            $overlay.removeClass('active');
        }
    }

    function syncComposeOverlays() {
        const showHud = freecamActive && overlayState.hudInfo;
        const showGrid = freecamActive && overlayState.grid;
        $('#compose-grid').toggleClass('hidden', !showGrid);
        $('#hud-info').toggleClass('hidden', !showHud);
        if (!freecamActive) {
            $('#hud-boost').addClass('hidden');
        }
    }

    function setFreecamActive(active) {
        freecamActive = !!active;
        if (!freecamActive) {
            cinematicState.enabled = false;
            $('#cinematic-enabled').prop('checked', false);
            $('#cinematic-overlay').removeClass('active');
            $('#compose-grid').addClass('hidden');
            $('#hud-info').addClass('hidden');
            $('#hud-boost').addClass('hidden');
        }
        syncComposeOverlays();
        syncCinematicOverlay();
    }

    function renderControls(controls) {
        const $c = $('#controls-container').empty();
        (controls || []).forEach((item) => {
            $c.append(
                $('<div>').addClass('control-item').append(
                    $('<span>').addClass('key').text(item.key),
                    $('<span>').addClass('description').text(item.description)
                )
            );
        });
    }

    function orderedFilters() {
        const entries = [];
        const used = {};
        (filterOrder || []).forEach((key) => {
            if (filterList[key]) {
                entries.push([key, filterList[key]]);
                used[key] = true;
            }
        });
        Object.entries(filterList).forEach(([key, filter]) => {
            if (!used[key]) entries.push([key, filter]);
        });
        return entries;
    }

    function renderFilters() {
        const $c = $('#filters-container').empty();
        orderedFilters().forEach(([key, filter]) => {
            const $item = $('<div>')
                .addClass('filter-item')
                .toggleClass('active', key === currentFilter)
                .attr('data-filter', key)
                .append(
                    $('<div>').addClass('filter-preview').addClass(key),
                    $('<div>').addClass('filter-name').text(filter.name)
                );
            $c.append($item);
        });
    }

    function renderPositions(positions) {
        const $c = $('#positions-container').empty();
        if (!positions || !positions.length) {
            $c.append($('<div>').addClass('no-positions').text(t('no_positions', 'Henüz kayıt yok')));
            return;
        }

        positions.forEach((pos) => {
            const metas = [];
            if (pos.filter && filterList[pos.filter]) metas.push(filterList[pos.filter].name);
            if (pos.emote && (pos.emote.label || pos.emote.name)) {
                metas.push(pos.emote.label || pos.emote.name);
            }

            const $item = $('<div>').addClass('position-item');
            const $info = $('<div>').addClass('position-info').append(
                $('<div>').addClass('position-name').text(pos.name)
            );
            if (metas.length) {
                $info.append($('<div>').addClass('position-meta').text(metas.join(' · ')));
            }

            const $load = $('<button>').addClass('load-btn').text(t('load', 'Yükle')).on('click', function () {
                nuiPost('loadPosition', { id: pos.id });
            });
            const $del = $('<button>').addClass('delete-btn').text(t('delete', 'Sil')).on('click', function (e) {
                e.preventDefault();
                pendingDeleteId = pos.id;
                $('#delete-confirm-modal').removeClass('hidden');
                syncFocus(true);
            });

            $item.append($info, $('<div>').addClass('position-actions').append($load, $del));
            $c.append($item);
        });
    }

    function applyUiConfig(cfg) {
        if (!cfg) return;
        if (cfg.strings) applyI18n(cfg.strings);
        if (cfg.locale) document.documentElement.lang = cfg.locale;
        if (cfg.title) $('#menu-title').text(cfg.title);
        if (cfg.subtitle) $('#menu-subtitle').text(cfg.subtitle);
        if (cfg.themes) themes = cfg.themes;
        if (cfg.theme) applyTheme(cfg.theme);
        if (cfg.controls) renderControls(cfg.controls);
        if (cfg.filterList) {
            filterList = cfg.filterList;
            filterOrder = cfg.filterOrder || [];
            if (cfg.currentFilter) currentFilter = cfg.currentFilter;
            renderFilters();
        }
        if (cfg.filterStrength != null) {
            $('#filter-strength').val(cfg.filterStrength);
            $('#filter-strength-value').text(Number(cfg.filterStrength).toFixed(2));
        }
        if (cfg.cinematic) applyCinematic(cfg.cinematic);
        if (cfg.overlay) applyOverlay(cfg.overlay);
    }

    function applyCinematic(state) {
        if (!state) return;
        ignoreSync = true;
        cinematicState = {
            enabled: !!state.enabled,
            letterboxSize: Number(state.letterboxSize ?? 0.12)
        };
        $('#cinematic-enabled').prop('checked', cinematicState.enabled);
        $('#letterbox-slider').val(cinematicState.letterboxSize);
        $('#letterbox-value').text(cinematicState.letterboxSize.toFixed(2));
        syncCinematicOverlay();
        ignoreSync = false;
    }

    function applyOverlay(state) {
        if (!state) return;
        ignoreSync = true;
        overlayState = {
            grid: !!state.grid,
            hudInfo: state.hudInfo !== false,
            lookAtPed: !!state.lookAtPed,
            smoothCam: state.smoothCam !== false
        };
        $('#opt-grid').prop('checked', overlayState.grid);
        $('#opt-hud').prop('checked', overlayState.hudInfo);
        $('#opt-lookat').prop('checked', overlayState.lookAtPed);
        $('#opt-smooth').prop('checked', overlayState.smoothCam);
        syncComposeOverlays();
        ignoreSync = false;
    }

    function closeModals() {
        $('#save-position-modal, #delete-confirm-modal').addClass('hidden');
        $('#position-name').val('');
        pendingDeleteId = null;
        $('#delete-confirm').prop('disabled', false).text('Sil');
    }

    function closeHelp() {
        closeModals();
        $('#help-menu').addClass('hidden');
        nuiPost('closeHelp', {});
        syncFocus(false);
    }

    // Tabs
    $(document).on('click', '.rail-btn', function () {
        const tab = $(this).data('tab');
        $('.rail-btn').removeClass('active');
        $('.tab-pane').removeClass('active');
        $(this).addClass('active');
        $('#' + tab + '-tab').addClass('active');
    });

    $('#close-panel').on('click', closeHelp);

    $(document).on('click', '.filter-item', function () {
        const filter = $(this).attr('data-filter') || $(this).data('filter');
        if (!filter) return;
        currentFilter = filter;
        $('.filter-item').removeClass('active');
        $(this).addClass('active');
        nuiPost('changeFilter', { filter: String(filter) });
    });

    function pushFilterStrength(v) {
        pendingStrength = v;
        clearTimeout(strengthTimer);
        strengthTimer = setTimeout(function () {
            if (pendingStrength == null) return;
            nuiPost('setFilterStrength', { strength: pendingStrength });
            pendingStrength = null;
        }, 90);
    }

    $('#filter-strength').on('input', function () {
        const v = Math.max(0.05, Math.min(1, parseFloat($(this).val()) || 1));
        $('#filter-strength-value').text(v.toFixed(2));
        pushFilterStrength(v);
    });
    $('#filter-strength').on('change', function () {
        const v = Math.max(0.05, Math.min(1, parseFloat($(this).val()) || 1));
        $('#filter-strength-value').text(v.toFixed(2));
        clearTimeout(strengthTimer);
        pendingStrength = null;
        nuiPost('setFilterStrength', { strength: v });
    });

    $('#cinematic-enabled').on('change', function () {
        if (ignoreSync) return;
        cinematicState.enabled = $(this).is(':checked');
        syncCinematicOverlay();
        nuiPost('updateCinematicSettings', { enabled: cinematicState.enabled });
    });

    let letterboxDebounce;
    $('#letterbox-slider').on('input', function () {
        if (ignoreSync) return;
        const v = parseFloat($(this).val()) || 0.12;
        cinematicState.letterboxSize = v;
        $('#letterbox-value').text(v.toFixed(2));
        syncCinematicOverlay();
        clearTimeout(letterboxDebounce);
        letterboxDebounce = setTimeout(function () {
            nuiPost('updateCinematicSettings', { letterboxSize: v });
        }, 60);
    });

    function bindOverlayToggle(id, key) {
        $('#' + id).on('change', function () {
            if (ignoreSync) return;
            overlayState[key] = $(this).is(':checked');
            syncComposeOverlays();
            const payload = {};
            payload[key] = overlayState[key];
            nuiPost('updateOverlaySettings', payload);
        });
    }

    bindOverlayToggle('opt-grid', 'grid');
    bindOverlayToggle('opt-hud', 'hudInfo');
    bindOverlayToggle('opt-lookat', 'lookAtPed');
    bindOverlayToggle('opt-smooth', 'smoothCam');

    $('.theme-swatch').on('click', function () {
        const theme = $(this).data('theme');
        applyTheme(theme);
        nuiPost('updateSettings', { type: 'theme', value: theme });
    });

    $('#save-position').on('click', function () {
        $('#save-position-modal').removeClass('hidden');
        $('#position-name').trigger('focus');
        syncFocus(true);
    });

    $('#save-position-cancel').on('click', function () {
        closeModals();
        syncFocus();
    });

    $('#save-position-confirm').on('click', function () {
        const name = $('#position-name').val().trim();
        if (!name) return;
        nuiPost('savePosition', { name: name });
        closeModals();
        syncFocus();
    });

    $('#delete-confirm').on('click', function () {
        if (pendingDeleteId == null) return;
        const $btn = $(this);
        $btn.prop('disabled', true).text('...');
        nuiPost('deletePosition', { id: pendingDeleteId }).finally(function () {
            closeModals();
            syncFocus();
        });
    });

    $('#delete-cancel').on('click', function () {
        closeModals();
        syncFocus();
    });

    $(document).on('keyup', function (e) {
        if (e.key !== 'Escape') return;
        if (isModalOpen()) {
            closeModals();
            syncFocus();
            return;
        }
        if (isHelpVisible()) closeHelp();
    });

    window.addEventListener('message', function (event) {
        const data = event.data;
        if (!data || !data.type) return;

        switch (data.type) {
            case 'toggleHelp':
                if (data.uiConfig) applyUiConfig(data.uiConfig);
                if (data.display) {
                    $('#help-menu').removeClass('hidden');
                } else {
                    closeModals();
                    $('#help-menu').addClass('hidden');
                }
                break;

            case 'updateFilter':
                currentFilter = data.filter;
                renderFilters();
                if (data.strength != null) {
                    $('#filter-strength').val(data.strength);
                    $('#filter-strength-value').text(Number(data.strength).toFixed(2));
                }
                $('#hud-filter').text(String(data.filter || 'normal').toUpperCase());
                break;

            case 'updatePositions':
                if (data.filterList) {
                    filterList = data.filterList;
                    renderFilters();
                }
                if (data.currentFilter) currentFilter = data.currentFilter;
                renderPositions(data.positions);
                break;

            case 'updateCinematic':
                applyCinematic(data.cinematic);
                break;

            case 'updateOverlay':
                if (typeof data.freecamActive === 'boolean') {
                    freecamActive = data.freecamActive;
                }
                applyOverlay(data.overlay);
                if (data.overlay && data.overlay.fov != null) {
                    $('#hud-fov').text('FOV ' + Math.round(data.overlay.fov));
                }
                if (data.overlay && data.overlay.filter) {
                    $('#hud-filter').text(String(data.overlay.filter).toUpperCase());
                }
                break;

            case 'freecamState':
                setFreecamActive(!!data.active);
                break;

            case 'hudTick':
                if (!freecamActive) break;
                if (data.fov != null) $('#hud-fov').text('FOV ' + Math.round(data.fov));
                if (data.filter) $('#hud-filter').text(String(data.filter).toUpperCase());
                $('#hud-boost').toggleClass('hidden', !data.boosting);
                break;

            case 'openSaveModal':
                $('#save-position-modal').removeClass('hidden');
                $('#position-name').trigger('focus');
                syncFocus(true);
                break;

            case 'closeUI':
                closeModals();
                $('#help-menu').addClass('hidden');
                syncFocus(false);
                break;

            case 'resetSessionFx':
                clearTimeout(strengthTimer);
                pendingStrength = null;
                applyCinematic({ enabled: false, letterboxSize: 0.12 });
                currentFilter = 'normal';
                renderFilters();
                $('#filter-strength').val(1);
                $('#filter-strength-value').text('1.00');
                $('#cinematic-overlay').removeClass('active');
                $('#compose-grid').addClass('hidden');
                $('#hud-info').addClass('hidden');
                $('#hud-boost').addClass('hidden');
                break;
        }
    });
});
