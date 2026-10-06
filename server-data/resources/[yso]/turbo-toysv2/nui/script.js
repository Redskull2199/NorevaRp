// ============================================================
// TURBO TOYS - NUI script (locale + sound + toggle)
// ============================================================

// Use FiveM's parent resource name so post() always hits the right
// endpoint even if the resource folder is renamed at deploy time.
const RESOURCE = (typeof GetParentResourceName === 'function')
  ? GetParentResourceName()
  : 'turbo-toysv2';
const root     = document.getElementById('root');
const screens  = document.querySelectorAll('.screen');

const elDefault     = document.getElementById('default-list');
const elUserList    = document.getElementById('user-list');
const elUserEmpty   = document.getElementById('user-empty');
const elUserCount   = document.getElementById('user-count');
const elVehicleList = document.getElementById('vehicle-bone-list');
const elMainLabel   = document.getElementById('main-toy-label');
const elPosLabel    = document.getElementById('positions-toy-label');

let state = {
  isOpen: false,
  screen: 'main',
  defaults: [],
  users: [],
  vehicleBones: [],
  toyLabel: '',
  itemName: '',
  boundId: null,
  activeSource: 'default',
  activeKey: 1,
  localeCode: 'tr',
  scale: {
    current: 1.0,
    default: 1.0,
    min: 0.30,
    max: 2.50,
    step: 0.05,
    bigStep: 0.10,
  },
};

// ============================================================
// LOCALE: Lua'dan gelen UI text dict'i
// ============================================================
let T = {
  // Default TR fallback (Lua locale gelmezse)
  menu_title: 'TOY MENU',
  close_kbd: 'KAPAT',
  action_position: 'Pozisyon Seç',
  action_position_desc: 'tutuş şeklini ayarla',
  action_gizmo: '3D Gizmo',
  action_gizmo_desc: 'serbest yerleştir + kaydet',
  action_light: 'Işık Saç',
  action_light_desc: 'parlama efekti',
  action_back: 'Geri',
  section_defaults: 'VARSAYILAN',
  section_user: 'KAYDEDİLEN',
  section_settings: 'AYARLAR',
  no_user_positions: 'Henüz kayıt yok.',
  bound_default: 'Varsayılan',
  tooltip_set_default: 'Varsayılan yap',
  tooltip_unset_default: 'Varsayılanı kaldır',
  tooltip_delete: 'Sil',
  setting_sound: 'Ses Efekti',
  setting_sound_on: 'Açık',
  setting_sound_off: 'Kapalı',
  confirm_title: 'Emin misin?',
  confirm_delete_text: '"%s" pozisyonunu silmek istediğine emin misin?',
  confirm_cancel: 'İptal',
  confirm_delete: 'Sil',
  gizmo_mode_translate: 'KONUM',
  gizmo_mode_rotate: 'YÖN',
  gizmo_drag_translate: 'TAŞIYORUM',
  gizmo_drag_rotate: 'DÖNDÜRÜYORUM',
  // Scale
  action_scale: 'Boyut Ayarla',
  action_scale_desc: 'prop büyüklüğünü değiştir',
  scale_title: 'BOYUT',
  scale_current: 'MEVCUT',
  scale_default: 'VARSAYILAN',
  scale_reset: 'SIFIRLA',
  scale_hint: 'Sürükle veya butonlarla ayarla',
};

function t(key, ...args) {
  let s = T[key] || key;
  if (args.length > 0) {
    let i = 0;
    s = s.replace(/%s/g, () => (args[i++] !== undefined ? String(args[i-1]) : ''));
  }
  return s;
}

function applyLocale() {
  // Static text: <span data-t="key">
  document.querySelectorAll('[data-t]').forEach(el => {
    const k = el.dataset.t;
    if (T[k]) el.textContent = T[k];
  });
  // HTML text: <span data-t-html="key"> (allows <strong> etc)
  document.querySelectorAll('[data-t-html]').forEach(el => {
    const k = el.dataset.tHtml;
    if (T[k]) el.innerHTML = T[k];
  });
}

// ============================================================
// SOUND: click.mp3 her tikta calar, toggle ile acilip kapanir
// ============================================================
const clickAudio = document.getElementById('click-sound');
if (clickAudio) clickAudio.volume = 0.40;

let soundEnabled = true;
try {
  const stored = localStorage.getItem('turbo-toysv2.sound');
  if (stored === 'off') soundEnabled = false;
} catch (e) { /* localStorage might be blocked */ }

function playClick() {
  if (!soundEnabled || !clickAudio) return;
  try {
    // Clone for rapid overlapping clicks
    const a = clickAudio.cloneNode();
    a.volume = clickAudio.volume;
    const p = a.play();
    if (p && p.catch) p.catch(() => {});
  } catch (e) { /* ignore */ }
}

// Delegate clicks on all interactive elements -> play sound
document.body.addEventListener('click', (e) => {
  const target = e.target.closest('.row, .icon-btn, .cta, .confirm-btn, .gizmo-tab');
  if (target) playClick();
}, true);  // capture phase, fires before action handlers

function updateSoundUI() {
  const label = document.getElementById('sound-state-label');
  const sw    = document.getElementById('sound-switch');
  if (label) label.textContent = soundEnabled ? t('setting_sound_on') : t('setting_sound_off');
  if (sw)    sw.dataset.on = soundEnabled ? 'true' : 'false';
}

function toggleSound() {
  soundEnabled = !soundEnabled;
  try { localStorage.setItem('turbo-toysv2.sound', soundEnabled ? 'on' : 'off'); }
  catch (e) {}
  updateSoundUI();
  // Play a click so user hears confirmation when turning ON
  if (soundEnabled) playClick();
}

/* ---------- helpers ---------- */
function show()  { root.classList.remove('hidden'); }
function hide()  { root.classList.add('hidden'); }

function gotoScreen(name) {
  state.screen = name;
  screens.forEach(s => s.classList.toggle('hidden', s.dataset.screen !== name));
}

function post(endpoint, data = {}) {
  return fetch(`https://${RESOURCE}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }).catch(() => ({}));
}

function close() {
  state.isOpen = false;
  hide();
  gotoScreen('main');
  post('close');
}

function escapeHtml(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* ---------- custom confirm modal ---------- */
function customConfirm(text) {
  return new Promise((resolve) => {
    const modal  = document.getElementById('confirm-modal');
    const title  = document.getElementById('confirm-title');
    const txt    = document.getElementById('confirm-text');
    const ok     = document.getElementById('confirm-ok');
    const cancel = document.getElementById('confirm-cancel');
    if (title)  title.textContent  = t('confirm_title');
    if (ok)     ok.textContent     = t('confirm_delete');
    if (cancel) cancel.textContent = t('confirm_cancel');
    txt.textContent = text;
    modal.classList.remove('hidden');

    const cleanup = (result) => {
      modal.classList.add('hidden');
      ok.onclick = null;
      cancel.onclick = null;
      document.removeEventListener('keydown', onKey, true);
      resolve(result);
    };
    const onKey = (e) => {
      if (e.key === 'Enter')      { e.stopPropagation(); e.preventDefault(); cleanup(true); }
      else if (e.key === 'Escape'){ e.stopPropagation(); e.preventDefault(); cleanup(false); }
    };
    ok.onclick     = () => cleanup(true);
    cancel.onclick = () => cleanup(false);
    document.addEventListener('keydown', onKey, true);
  });
}

/* ---------- SAVE DIALOG (gizmo kaydet) ---------- */
function openSaveDialogUI(defaultLabel) {
  const dialog = document.getElementById('save-dialog');
  const input  = document.getElementById('save-name-input');
  const check  = document.getElementById('save-default-check');
  const okBtn  = document.getElementById('save-ok');
  const cnBtn  = document.getElementById('save-cancel');

  input.value = defaultLabel || '';
  input.placeholder = t('save_name_placeholder');
  check.checked = true;
  dialog.classList.remove('hidden');

  // gizmo aciksa root gizmo-only mode'da, save dialog'u gostermek icin aç
  root.classList.remove('gizmo-only');
  show();

  // input'a focus + secili (kolay yazim)
  setTimeout(() => { try { input.focus(); input.select(); } catch (e) {} }, 60);

  const submit = () => {
    const label = (input.value || '').trim();
    if (label.length === 0) {
      input.focus();
      input.style.borderColor = 'rgba(244, 63, 94, 0.60)';
      setTimeout(() => { input.style.borderColor = ''; }, 600);
      return;
    }
    closeSaveDialogUI();
    post('gizmoSaveSubmit', { label: label, makeDefault: check.checked });
  };
  const cancel = () => {
    closeSaveDialogUI();
    post('gizmoSaveCancel', {});
  };

  okBtn.onclick = submit;
  cnBtn.onclick = cancel;

  const onKey = (e) => {
    if (e.key === 'Enter')      { e.preventDefault(); e.stopPropagation(); submit(); document.removeEventListener('keydown', onKey, true); }
    else if (e.key === 'Escape'){ e.preventDefault(); e.stopPropagation(); cancel(); document.removeEventListener('keydown', onKey, true); }
  };
  document.addEventListener('keydown', onKey, true);
}

function closeSaveDialogUI() {
  document.getElementById('save-dialog').classList.add('hidden');
}

/* ---------- render: default positions ---------- */
function renderDefaults() {
  elDefault.innerHTML = '';
  state.defaults.forEach((p, idx) => {
    const i = idx + 1;
    const isActive = state.activeSource === 'default' && state.activeKey === p.key;
    const btn = document.createElement('button');
    btn.className = 'row' + (isActive ? ' row-active' : '');
    btn.dataset.source = 'default';
    btn.dataset.key = p.key;
    btn.innerHTML = `
      <span class="dot ${i % 2 ? 'dot-rose' : 'dot-amber'}"></span>
      <span class="row-text">
        <span class="row-label">${escapeHtml(p.label)}</span>
        <span class="row-meta">#${i}</span>
      </span>
      <span class="kbd">${escapeHtml(p.shortcut || String(i))}</span>
    `;
    btn.addEventListener('click', () => {
      post('selectPosition', { source: 'default', key: p.key });
      close();
    });
    elDefault.appendChild(btn);
  });
}

/* ---------- render: vehicle bones (positions screen ARAÇ section) ---------- */
function renderVehicleBones() {
  if (!elVehicleList) return;
  elVehicleList.innerHTML = '';
  state.vehicleBones.forEach((b, idx) => {
    const btn = document.createElement('button');
    btn.className = 'row';
    btn.dataset.boneId = b.id;
    btn.innerHTML = `
      <span class="dot dot-cyan"></span>
      <span class="row-text">
        <span class="row-label">${escapeHtml(b.label)}</span>
        <span class="row-meta">${escapeHtml(b.id)}</span>
      </span>
      <span class="kbd">▸</span>
    `;
    btn.addEventListener('click', () => {
      post('selectVehicleBone', { boneId: b.id });
      close();
    });
    elVehicleList.appendChild(btn);
  });
}

/* ---------- render: user positions ---------- */
function renderUsers() {
  elUserList.querySelectorAll('.user-row').forEach(n => n.remove());
  elUserCount.textContent = state.users.length;

  if (state.users.length === 0) {
    elUserEmpty.classList.remove('hidden');
    return;
  }
  elUserEmpty.classList.add('hidden');

  state.users.forEach(p => {
    const isActive = state.activeSource === 'user' && state.activeKey === p.key;
    const isBound  = state.boundId === p.key;

    const wrap = document.createElement('div');
    wrap.className = 'user-row' + (isActive ? ' row-active' : '');

    const boundBadge = isBound ? `<span class="badge">★ ${escapeHtml(t('bound_default'))}</span>` : '';
    const bindTitle  = isBound ? t('tooltip_unset_default') : t('tooltip_set_default');
    const delTitle   = t('tooltip_delete');

    wrap.innerHTML = `
      <button class="row row-pick" data-key="${p.key}">
        <span class="dot dot-violet"></span>
        <span class="row-text">
          <span class="row-label">${escapeHtml(p.label)} ${boundBadge}</span>
        </span>
      </button>
      <div class="row-controls">
        <button class="icon-btn ${isBound ? 'icon-btn-active' : ''}" data-act="bind" data-key="${p.key}" title="${bindTitle}">★</button>
        <button class="icon-btn icon-btn-danger" data-act="del" data-key="${p.key}" title="${delTitle}">✕</button>
      </div>
    `;

    wrap.querySelector('.row-pick').addEventListener('click', () => {
      post('selectPosition', { source: 'user', key: p.key });
      close();
    });
    wrap.querySelector('[data-act="bind"]').addEventListener('click', (e) => {
      e.stopPropagation();
      if (isBound) {
        post('unbindPosition');
        state.boundId = null;
      } else {
        post('bindPosition', { positionId: p.key });
        state.boundId = p.key;
      }
      renderUsers();
    });
    wrap.querySelector('[data-act="del"]').addEventListener('click', async (e) => {
      e.stopPropagation();
      const ok = await customConfirm(t('confirm_delete_text', p.label));
      if (!ok) return;
      post('deletePosition', { positionId: p.key });
      state.users = state.users.filter(x => x.key !== p.key);
      if (state.boundId === p.key) state.boundId = null;
      renderUsers();
    });

    elUserList.appendChild(wrap);
  });
}

/* ---------- render: scale screen ---------- */
function clampScale(s) {
  s = Number(s);
  if (!isFinite(s)) s = 1.0;
  const lo = state.scale.min;
  const hi = state.scale.max;
  if (s < lo) s = lo;
  if (s > hi) s = hi;
  return Math.round(s * 100) / 100;  // 2 ondalik
}

function renderScale() {
  const sc      = state.scale;
  const valueEl = document.getElementById('scale-value');
  const defEl   = document.getElementById('scale-default-num');
  const slider  = document.getElementById('scale-slider');
  const fill    = document.getElementById('scale-slider-fill');
  const defMark = document.getElementById('scale-slider-default');
  const minLbl  = document.getElementById('scale-min-label');
  const maxLbl  = document.getElementById('scale-max-label');

  if (!slider) return;

  slider.min   = sc.min.toFixed(2);
  slider.max   = sc.max.toFixed(2);
  slider.step  = (sc.step || 0.05).toString();
  slider.value = clampScale(sc.current).toFixed(2);

  // Update readouts
  valueEl.textContent = clampScale(sc.current).toFixed(2);
  defEl.textContent   = clampScale(sc.default).toFixed(2) + '×';
  minLbl.textContent  = sc.min.toFixed(2) + '×';
  maxLbl.textContent  = sc.max.toFixed(2) + '×';

  // Fill bar
  const pct = ((sc.current - sc.min) / (sc.max - sc.min)) * 100;
  fill.style.width = Math.max(0, Math.min(100, pct)) + '%';

  // Default marker pos
  const defPct = ((sc.default - sc.min) / (sc.max - sc.min)) * 100;
  defMark.style.left = Math.max(0, Math.min(100, defPct)) + '%';

  // Toy label in footer
  document.getElementById('scale-toy-label').textContent = state.toyLabel || 'TURBO TOYS';

  // Active-state visual (default mi degil mi)
  valueEl.classList.toggle('scale-modified', Math.abs(sc.current - sc.default) > 0.001);
}

/* ---------- live scale apply (slider drag) ---------- */
// Slider input -> apply live with throttle. The Lua side has its own
// 250ms server throttle. We still want local UI to update at 60fps.
let scaleSendTimer = null;
function applyScaleLive(newScale, finalCommit) {
  const s = clampScale(newScale);
  state.scale.current = s;

  // UI update immediate (no debounce on visual)
  const valueEl = document.getElementById('scale-value');
  const fill    = document.getElementById('scale-slider-fill');
  if (valueEl) {
    valueEl.textContent = s.toFixed(2);
    valueEl.classList.toggle('scale-modified', Math.abs(s - state.scale.default) > 0.001);
  }
  if (fill) {
    const pct = ((s - state.scale.min) / (state.scale.max - state.scale.min)) * 100;
    fill.style.width = Math.max(0, Math.min(100, pct)) + '%';
  }

  // Server call: throttled to 80ms during drag, immediate on final commit
  if (finalCommit) {
    if (scaleSendTimer) { clearTimeout(scaleSendTimer); scaleSendTimer = null; }
    post('setScale', { scale: s, persist: true });
  } else {
    if (scaleSendTimer) return;
    scaleSendTimer = setTimeout(() => {
      scaleSendTimer = null;
      post('setScale', { scale: s, persist: true });
    }, 80);
  }
}

function bumpScale(delta) {
  applyScaleLive(state.scale.current + delta, true);
  const slider = document.getElementById('scale-slider');
  if (slider) slider.value = clampScale(state.scale.current).toFixed(2);
}

function resetScaleUI() {
  state.scale.current = state.scale.default;
  const slider = document.getElementById('scale-slider');
  if (slider) slider.value = state.scale.default.toFixed(2);
  // Reset gercek scale'i client'a soyle
  post('resetScale');
  renderScale();
}

/* ---------- bind scale screen events (ONCE on load) ---------- */
function initScaleScreen() {
  const slider = document.getElementById('scale-slider');
  if (slider && !slider.dataset.bound) {
    slider.dataset.bound = '1';
    slider.addEventListener('input', (e) => {
      applyScaleLive(parseFloat(e.target.value), false);
    });
    slider.addEventListener('change', (e) => {
      applyScaleLive(parseFloat(e.target.value), true);
    });
  }

  // Quick step buttons (delegation on the buttons container)
  document.querySelectorAll('[data-scale-step]').forEach(btn => {
    if (btn.dataset.bound) return;
    btn.dataset.bound = '1';
    btn.addEventListener('click', () => {
      bumpScale(parseFloat(btn.dataset.scaleStep));
    });
  });

  // Reset CTA
  const resetBtn = document.querySelector('[data-action="reset-scale"]');
  if (resetBtn && !resetBtn.dataset.bound) {
    resetBtn.dataset.bound = '1';
    resetBtn.addEventListener('click', () => {
      resetScaleUI();
    });
  }
}

/* ---------- main screen actions ---------- */
document.addEventListener('click', (e) => {
  // Sound toggle
  const toggle = e.target.closest('[data-action="toggle-sound"]');
  if (toggle) {
    e.preventDefault();
    e.stopPropagation();
    toggleSound();
    return;
  }

  const row = e.target.closest('.row[data-action]');
  const cta = e.target.closest('.cta[data-action]');
  const target = row || cta;
  if (!target) return;

  const action = target.dataset.action;
  if (action === 'position')        gotoScreen('positions');
  else if (action === 'gizmo')      { post('openGizmo'); state.isOpen = false; hide(); }
  else if (action === 'open-gizmo') { post('openGizmo'); state.isOpen = false; hide(); }
  else if (action === 'place-vehicle') { post('openGizmoVehicle'); state.isOpen = false; hide(); }
  else if (action === 'light')      { post('emitLight'); close(); }
  else if (action === 'scale')      { gotoScreen('scale'); renderScale(); }
  else if (action === 'drop-focused') { post('dropFocusedToy'); close(); }
  else if (action === 'drop-all')   { post('dropAllToys'); close(); }
});

/* ---------- keyboard ---------- */
document.addEventListener('keydown', (e) => {
  if (!state.isOpen) return;
  const confirmOpen = !document.getElementById('confirm-modal').classList.contains('hidden');
  const saveOpen    = !document.getElementById('save-dialog').classList.contains('hidden');
  if (confirmOpen || saveOpen) return;

  if (e.key === 'Escape' || e.key === 'Esc') {
    e.preventDefault();
    if (state.screen === 'positions') gotoScreen('main');
    else if (state.screen === 'scale') gotoScreen('main');
    else close();
    return;
  }

  if (state.screen === 'main') {
    if (e.key === '1') gotoScreen('positions');
    else if (e.key === '2') { post('openGizmo'); state.isOpen = false; hide(); }
    else if (e.key === '3') { post('emitLight'); close(); }
    else if (e.key === '4') { gotoScreen('scale'); renderScale(); }
    else if (e.key === 'v' || e.key === 'V') { post('openGizmoVehicle'); state.isOpen = false; hide(); }
    else if (e.key === 'x' || e.key === 'X') { post('dropFocusedToy'); close(); }
    else if (e.key === 'z' || e.key === 'Z') { post('dropAllToys'); close(); }
    return;
  }

  if (state.screen === 'positions') {
    const n = parseInt(e.key, 10);
    if (!isNaN(n) && n >= 1 && n <= state.defaults.length) {
      const p = state.defaults[n - 1];
      post('selectPosition', { source: 'default', key: p.key });
      close();
    }
    return;
  }

  if (state.screen === 'scale') {
    // Arrow keys: fine adjustment
    if (e.key === 'ArrowRight' || e.key === 'ArrowUp') {
      e.preventDefault();
      const big = e.shiftKey ? state.scale.bigStep : state.scale.step;
      bumpScale(big);
    } else if (e.key === 'ArrowLeft' || e.key === 'ArrowDown') {
      e.preventDefault();
      const big = e.shiftKey ? state.scale.bigStep : state.scale.step;
      bumpScale(-big);
    } else if (e.key === '0' || e.key === 'r' || e.key === 'R') {
      e.preventDefault();
      resetScaleUI();
    }
  }
});

/* ---------- CUSTOM NOTIFY (sag ust stack) ---------- */
function ttNotify(message, ntype, title, duration) {
  const stack = document.getElementById('tt-notify-stack');
  if (!stack) return;
  const safeType = ({success:1,error:1,inform:1,warning:1}[ntype]) ? ntype : 'inform';
  const icons   = { success: '✓', error: '!', inform: 'i', warning: '⚠' };
  const titles  = { success: 'OK', error: 'HATA', inform: 'BILGI', warning: 'UYARI' };

  const item = document.createElement('div');
  item.className = 'tt-notify-item ' + safeType;
  item.innerHTML =
    '<div class="tt-notify-bar"></div>' +
    '<div class="tt-notify-body">' +
      '<div class="tt-notify-icon">' + icons[safeType] + '</div>' +
      '<div class="tt-notify-text">' +
        '<div class="tt-notify-title"></div>' +
        '<div class="tt-notify-message"></div>' +
      '</div>' +
    '</div>';
  // textContent for safety against arbitrary strings
  item.querySelector('.tt-notify-title').textContent   = (title && String(title)) || titles[safeType];
  item.querySelector('.tt-notify-message').textContent = String(message || '');
  stack.appendChild(item);

  const ms = Math.max(1500, Number(duration) || 3500);
  setTimeout(() => {
    item.classList.add('out');
    setTimeout(() => { if (item.parentNode) item.parentNode.removeChild(item); }, 250);
  }, ms);
}

/* ---------- NUI msg ---------- */
window.addEventListener('message', (event) => {
  const msg = event.data || {};
  if (msg.action === 'notify-show') {
    ttNotify(msg.message, msg.ntype, msg.title, msg.duration);
    return;
  }
  if (msg.action === 'open') {
    state.defaults     = msg.defaults || [];
    state.users        = msg.users || [];
    state.vehicleBones = msg.vehicleBones || [];
    state.toyLabel     = msg.toyLabel || '';
    state.itemName     = msg.itemName || '';
    state.boundId      = msg.boundId || null;
    state.activeSource = msg.activeSource || 'default';
    state.activeKey    = msg.activeKey;
    state.localeCode   = msg.localeCode || 'tr';

    // Scale info (Lua tarafindan dolduruluyor)
    if (msg.scale && typeof msg.scale === 'object') {
      state.scale = {
        current: Number(msg.scale.current) || 1.0,
        default: Number(msg.scale.default) || 1.0,
        min:     Number(msg.scale.min)     || 0.30,
        max:     Number(msg.scale.max)     || 2.50,
        step:    Number(msg.scale.step)    || 0.05,
        bigStep: Number(msg.scale.bigStep) || 0.10,
      };
    }

    // Locale strings'i Lua'dan al, default fallback'i override et
    if (msg.locale && typeof msg.locale === 'object') {
      Object.assign(T, msg.locale);
    }
    applyLocale();
    updateSoundUI();

    elMainLabel.textContent = state.toyLabel || 'TURBO TOYS';
    elPosLabel.textContent  = state.toyLabel || 'TURBO TOYS';

    // Background image
    const panel = document.querySelector('.panel');
    if (msg.bgUrl && msg.bgUrl.length > 0) {
      panel.style.setProperty('--menu-bg', `url('${msg.bgUrl.replace(/'/g, "\\'")}')`);
      panel.classList.add('has-bg');
    } else {
      panel.style.removeProperty('--menu-bg');
      panel.classList.remove('has-bg');
    }

    renderDefaults();
    renderUsers();
    renderVehicleBones();
    initScaleScreen();
    renderScale();

    state.isOpen = true;
    root.classList.remove('gizmo-only');
    gotoScreen('main');
    show();
  } else if (msg.action === 'close') {
    state.isOpen = false;
    hide();
  }
  /* ---------- SAVE DIALOG ---------- */
  else if (msg.action === 'gizmo:saveDialog') {
    if (msg.locale && typeof msg.locale === 'object') {
      Object.assign(T, msg.locale);
      applyLocale();
    }
    openSaveDialogUI(msg.defaultLabel || '');
  }
  /* ---------- GIZMO HUD ---------- */
  else if (msg.action === 'gizmo:open') {
    if (msg.locale && typeof msg.locale === 'object') {
      Object.assign(T, msg.locale);
      applyLocale();
    }
    document.getElementById('gz-toy').textContent  = msg.toy  || '—';
    document.getElementById('gz-mode').textContent = msg.mode === 'rotate' ? t('gizmo_mode_rotate') : t('gizmo_mode_translate');
    document.getElementById('gz-bone').textContent = msg.bone || '—';
    setGizmoTab(msg.mode);
    updateGizmoCoords(msg.pos, msg.rot);
    document.getElementById('gz-drag').classList.add('hidden');
    document.getElementById('gizmo-hud').classList.remove('hidden');
    root.classList.add('gizmo-only');
    show();
  } else if (msg.action === 'gizmo:close') {
    document.getElementById('gizmo-hud').classList.add('hidden');
    root.classList.remove('gizmo-only');
    if (!state.isOpen) hide();
  } else if (msg.action === 'gizmo:update') {
    if (msg.toy)  document.getElementById('gz-toy').textContent  = msg.toy;
    if (msg.mode) {
      document.getElementById('gz-mode').textContent = msg.mode === 'rotate' ? t('gizmo_mode_rotate') : t('gizmo_mode_translate');
      setGizmoTab(msg.mode);
    }
    if (msg.bone) document.getElementById('gz-bone').textContent = msg.bone;
    updateGizmoCoords(msg.pos, msg.rot);

    if (msg.dragging) {
      document.getElementById('gz-drag-action').textContent =
        (msg.dragging.kind === 'rotate' ? t('gizmo_drag_rotate') : t('gizmo_drag_translate'));
      document.getElementById('gz-drag-axis').textContent = (msg.dragging.axis || '?').toUpperCase();
      document.getElementById('gz-drag').classList.remove('hidden');
    } else if (msg.dragging === false) {
      document.getElementById('gz-drag').classList.add('hidden');
    }
  }
  /* ---------- CLAW MACHINE PROMPT ---------- */
  else if (msg.action === 'claw:prompt') {
    const el = document.getElementById('claw-prompt');
    if (!el) return;
    if (msg.show) {
      const titleEl  = document.getElementById('claw-prompt-title');
      const subEl    = document.getElementById('claw-prompt-sub');
      const keyEl    = document.getElementById('claw-prompt-key-letter');
      const keyBox   = keyEl ? keyEl.parentElement : null;
      if (msg.title && titleEl) titleEl.textContent = msg.title;
      if (msg.sub   && subEl)   subEl.textContent   = msg.sub;
      if (msg.key   && keyEl) {
        keyEl.textContent = msg.key;
        // Cok-karakterli tus (ENTER, SHIFT vs.) icin font'u kuçult, kutuyu genislet
        if (keyBox) keyBox.classList.toggle('long-key', msg.key.length > 1);
      }
      el.classList.remove('hidden');
    } else {
      el.classList.add('hidden');
    }
  }
});

function setGizmoTab(mode) {
  const t1 = document.getElementById('gz-tab-translate');
  const r1 = document.getElementById('gz-tab-rotate');
  if (!t1 || !r1) return;
  t1.classList.toggle('active', mode === 'translate');
  r1.classList.toggle('active', mode === 'rotate');
}

function updateGizmoCoords(pos, rot) {
  if (pos) {
    document.getElementById('gz-pos').textContent =
      pos.x.toFixed(3) + '  ' + pos.y.toFixed(3) + '  ' + pos.z.toFixed(3);
  }
  if (rot) {
    document.getElementById('gz-rot').textContent =
      rot.x.toFixed(1) + '  ' + rot.y.toFixed(1) + '  ' + rot.z.toFixed(1);
  }
}

// Initialize on load
applyLocale();
updateSoundUI();
hide();