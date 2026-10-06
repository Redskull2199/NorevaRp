/**
 * RoadCarPlay — Rear-Camera Proximity Overlay  (v5 — accurate zones + beep)
 *
 * Zone boundaries (bumper-face → obstacle, in metres):
 *   GREEN  : > 3.0 m  — clear
 *   YELLOW : 0.9 – 3.0 m  — caution, slow beep
 *   RED    : < 0.9 m  — danger, rapid beep (nearly continuous < 0.4 m)
 *
 * These values are tighter than v4 because the Lua layer now reports
 * true bumper-face distances (BUMPER_INSET compensated).
 *
 * Beep system (Web Audio API — no file needed):
 *   - Short 880 Hz tone, volume and repeat rate scale with distance.
 *   - Yellow zone: ~1 beep / 1.4 s → ~1 beep / 0.55 s as you close in.
 *   - Red zone:    ~1 beep / 0.35 s → continuous tone at < 0.3 m.
 *   - Beep fires immediately when zone changes to yellow or red.
 *
 * NUI messages consumed:
 *   { event: "SetCameraRearView",    cameraRearView: bool }
 *   { event: "UpdateCameraDistance", distance: float, reverseSpeed: float }
 */
(function () {
    'use strict';

    // ─── Zone table ───────────────────────────────────────────────────────
    var ZONES = [
        { name: 'green',  maxD: 9.0, r:  30, g: 230, b:  65 },
        { name: 'yellow', maxD: 3.0, r: 240, g: 185, b:   0 },
        { name: 'red',    maxD: 0.9, r: 240, g:  30, b:  20 },
    ];

    var BANDS = [
        { zone: ZONES[0], yTop: 0.00, yBot: 0.38 },
        { zone: ZONES[1], yTop: 0.38, yBot: 0.68 },
        { zone: ZONES[2], yTop: 0.68, yBot: 1.00 },
    ];

    function rgba(z, a) {
        return 'rgba(' + z.r + ',' + z.g + ',' + z.b + ',' + a.toFixed(3) + ')';
    }

    function activeZone(dist) {
        for (var i = ZONES.length - 1; i >= 0; i--) {
            if (dist <= ZONES[i].maxD) return ZONES[i];
        }
        return ZONES[0];
    }

    // ─── Beep system (Web Audio API) ──────────────────────────────────────
    var audioCtx     = null;
    var beepTimer    = null;
    var lastZoneName = 'green';

    function getAudioCtx() {
        if (!audioCtx) {
            try { audioCtx = new (window.AudioContext || window.webkitAudioContext)(); }
            catch (e) { audioCtx = null; }
        }
        return audioCtx;
    }

    /**
     * Fire a single short beep.
     * @param {number} freq     - Tone frequency in Hz (e.g. 880)
     * @param {number} duration - Duration in seconds (e.g. 0.09)
     * @param {number} volume   - Gain 0–1
     */
    function playBeep(freq, duration, volume) {
        var ctx = getAudioCtx();
        if (!ctx) return;
        // Resume if browser suspended the context (autoplay policy).
        if (ctx.state === 'suspended') { ctx.resume(); }
        var osc  = ctx.createOscillator();
        var gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type            = 'sine';
        osc.frequency.value = freq;
        gain.gain.setValueAtTime(volume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + duration);
        osc.start(ctx.currentTime);
        osc.stop(ctx.currentTime + duration + 0.01);
    }

    /**
     * Schedule repeating beeps whose interval shrinks as distance → 0.
     * Called whenever zone or distance changes meaningfully.
     */
    function scheduleBeeps(dist, zoneName) {
        clearBeeps();

        if (zoneName === 'green') return;   // silence in green

        var interval;
        if (zoneName === 'yellow') {
            // 1.4 s at 3.0 m → 0.55 s at 0.9 m  (linear interpolation)
            var t = Math.max(0, Math.min(1, (ZONES[1].maxD - dist) / (ZONES[1].maxD - ZONES[2].maxD)));
            interval = 1400 - t * 850;         // ms: 1400 → 550
        } else {
            // Red zone: 350 ms at 0.9 m → 80 ms at 0.3 m → near-continuous below
            if (dist < 0.3) {
                interval = 80;
            } else {
                var t2 = Math.max(0, Math.min(1, (ZONES[2].maxD - dist) / (ZONES[2].maxD - 0.3)));
                interval = 350 - t2 * 270;    // ms: 350 → 80
            }
        }

        var freq   = zoneName === 'red' ? 1050 : 820;
        var vol    = zoneName === 'red' ? 0.55  : 0.40;
        var dur    = zoneName === 'red' ? 0.075 : 0.085;

        // Fire the first beep immediately, then repeat.
        playBeep(freq, dur, vol);
        beepTimer = setInterval(function () {
            playBeep(freq, dur, vol);
        }, interval);
    }

    function clearBeeps() {
        if (beepTimer !== null) {
            clearInterval(beepTimer);
            beepTimer = null;
        }
    }

    // ─── State ────────────────────────────────────────────────────────────
    var state = {
        active:   false,
        distance: 9.0,
        speed:    0.0,
        phase:    0.0,
        lastTime: null,
        canvas:   null,
        rafId:    null,
        observer: null,
        // Beep re-schedule threshold: only reschedule when distance changes
        // by more than this amount to avoid constant timer resets.
        lastBeepDist: 9.0,
    };

    // ─── Canvas lifecycle ─────────────────────────────────────────────────
    function mountCanvas() {
        if (state.canvas) return;
        var c = document.createElement('canvas');
        c.id = 'rcp-cam-overlay';
        c.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:99999;';
        document.body.appendChild(c);
        state.canvas = c;
        fitCanvas();
        window.addEventListener('resize', fitCanvas);
    }
    function fitCanvas() {
        if (!state.canvas) return;
        state.canvas.width  = window.innerWidth;
        state.canvas.height = window.innerHeight;
    }
    function unmountCanvas() {
        window.removeEventListener('resize', fitCanvas);
        if (state.rafId) { cancelAnimationFrame(state.rafId); state.rafId = null; }
        if (state.canvas) { state.canvas.remove(); state.canvas = null; }
    }

    function setStaticVisible(v) {
        document.querySelectorAll('.camera-rear-view').forEach(function (el) {
            el.style.opacity = v ? '' : '0';
        });
    }
    function startObserver() {
        if (state.observer) return;
        state.observer = new MutationObserver(function () {
            if (state.active) setStaticVisible(false);
        });
        state.observer.observe(document.body, { childList: true, subtree: true });
    }
    function stopObserver() {
        if (state.observer) { state.observer.disconnect(); state.observer = null; }
    }

    // ─── Draw ─────────────────────────────────────────────────────────────
    function draw(ts) {
        if (!state.active || !state.canvas) return;

        if (!state.lastTime) state.lastTime = ts;
        var dt = Math.min((ts - state.lastTime) / 1000, 0.05);
        state.lastTime = ts;

        var az         = activeZone(state.distance);
        var dangerMult = az.name === 'red' ? 1.8 : az.name === 'yellow' ? 1.3 : 1.0;
        var speedMult  = 1.0 + Math.min(state.speed / 5.0, 1.0) * 0.5;
        state.phase    = (state.phase + 0.08 * dt * dangerMult * speedMult) % 1.0;

        var ctx = state.canvas.getContext('2d');
        var W   = state.canvas.width;
        var H   = state.canvas.height;
        ctx.clearRect(0, 0, W, H);

        var dist = state.distance;

        // ── Trapezoid geometry ─────────────────────────────────────────────
        var areaTop    = H * 0.48;
        var areaBottom = H * 0.97;
        var halfBottom = W * 0.47;
        var halfTop    = W * 0.155;
        var cx         = W * 0.5;

        function railX(y, side) {
            var t    = (y - areaTop) / (areaBottom - areaTop);
            var half = halfTop + (halfBottom - halfTop) * t;
            return cx + side * half;
        }

        // ── Zone bands ─────────────────────────────────────────────────────
        BANDS.forEach(function (band, bi) {
            var z         = band.zone;
            var isActive  = (z.name === az.name);
            var outerEdge = bi === 0 ? 9.0 : BANDS[bi - 1].zone.maxD;
            var entered   = dist <= outerEdge;

            var yTop = areaTop + (areaBottom - areaTop) * band.yTop;
            var yBot = areaTop + (areaBottom - areaTop) * band.yBot;

            // Boundary line at top of this band (skip the very first)
            if (bi > 0) {
                var lAlpha = isActive ? 1.0  : entered ? 0.40 : 0.14;
                var lWidth = isActive ? 3.5  : entered ? 1.6  : 1.0;
                var lBlur  = isActive ? 24   : entered ? 6    : 1;
                ctx.save();
                ctx.lineWidth   = lWidth;
                ctx.strokeStyle = rgba(z, lAlpha);
                ctx.shadowColor = rgba(z, isActive ? 0.95 : entered ? 0.25 : 0.04);
                ctx.shadowBlur  = lBlur;
                ctx.setLineDash([]);
                ctx.beginPath();
                ctx.moveTo(railX(yTop, -1), yTop);
                ctx.lineTo(railX(yTop,  1), yTop);
                ctx.stroke();
                ctx.restore();
            }

            if (!entered) return;

            // Solid fill tint when active
            if (isActive) {
                var hi   = bi === 0 ? 9.0 : BANDS[bi - 1].zone.maxD;
                var lo   = z.maxD;
                var prog = (hi - dist) / Math.max(hi - lo, 0.01);
                prog = Math.max(0, Math.min(1, prog));
                ctx.save();
                ctx.beginPath();
                ctx.moveTo(railX(yTop, -1), yTop);
                ctx.lineTo(railX(yTop,  1), yTop);
                ctx.lineTo(railX(yBot,  1), yBot);
                ctx.lineTo(railX(yBot, -1), yBot);
                ctx.closePath();
                ctx.fillStyle = rgba(z, 0.04 + prog * 0.10);
                ctx.fill();
                ctx.restore();
            }

            // Animated horizontal bands flowing toward the vehicle
            var N         = isActive ? 6  : 2;
            var baseAlpha = isActive ? 0.82 : 0.20;
            var spd       = isActive ? 1.3  : 0.35;

            for (var i = 0; i < N; i++) {
                var raw   = ((i / N) + state.phase * spd) % 1.0;
                var eased = 1.0 - Math.pow(1.0 - raw, 2.0);
                var y     = yTop + (yBot - yTop) * eased;
                var fade  = raw < 0.08 ? raw / 0.08 : raw > 0.90 ? (1 - raw) / 0.10 : 1.0;
                var alpha = baseAlpha * fade;
                if (alpha < 0.03) continue;

                ctx.save();
                ctx.lineWidth   = isActive ? 2.4 : 1.2;
                ctx.strokeStyle = rgba(z, alpha);
                ctx.shadowColor = rgba(z, alpha * 0.65);
                ctx.shadowBlur  = isActive ? 11 : 3;
                ctx.setLineDash([]);
                ctx.beginPath();
                ctx.moveTo(railX(y, -1), y);
                ctx.lineTo(railX(y,  1), y);
                ctx.stroke();
                ctx.restore();
            }
        });

        // ── Side rail dashes (active zone colour, flowing) ─────────────────
        ctx.save();
        ctx.lineWidth      = 2.4;
        ctx.setLineDash([22, 13]);
        ctx.lineDashOffset = -(state.phase * 35);
        ctx.strokeStyle    = rgba(az, 0.90);
        ctx.shadowColor    = rgba(az, 0.55);
        ctx.shadowBlur     = 15;
        [-1, 1].forEach(function (side) {
            ctx.beginPath();
            ctx.moveTo(railX(areaBottom, side), areaBottom);
            ctx.lineTo(railX(areaTop,    side), areaTop);
            ctx.stroke();
        });
        ctx.restore();

        // ── Bottom closing line (pulses red in danger zone) ────────────────
        var redZ     = ZONES[2];
        var redOn    = az.name === 'red';
        var redPulse = redOn ? 0.55 + 0.45 * Math.abs(Math.sin(ts * 0.007)) : 1.0;
        ctx.save();
        ctx.lineWidth   = redOn ? 3.5 * redPulse : 1.8;
        ctx.strokeStyle = rgba(redZ, redOn ? redPulse : 0.28);
        ctx.shadowColor = rgba(redZ, redOn ? 0.9 * redPulse : 0.08);
        ctx.shadowBlur  = redOn ? 22 * redPulse : 3;
        ctx.setLineDash([]);
        ctx.beginPath();
        ctx.moveTo(railX(areaBottom, -1), areaBottom);
        ctx.lineTo(railX(areaBottom,  1), areaBottom);
        ctx.stroke();
        ctx.restore();

        // ── Zone boundary labels ──────────────────────────────────────────
        var bndLabels = [
            { yFrac: 0.38, text: '3.0m', zi: 1 },
            { yFrac: 0.68, text: '0.9m', zi: 2 },
        ];
        bndLabels.forEach(function (ld) {
            var z      = ZONES[ld.zi];
            var isAct  = (z.name === az.name);
            var y      = areaTop + (areaBottom - areaTop) * ld.yFrac;
            var xRight = railX(y, 1) + 9;
            var outerEdge = ld.zi === 1 ? 9.0 : BANDS[ld.zi - 1].zone.maxD;
            var ent    = dist <= outerEdge;
            ctx.save();
            ctx.font        = 'bold 13px Arial, sans-serif';
            ctx.fillStyle   = rgba(z, isAct ? 1.0 : ent ? 0.48 : 0.18);
            ctx.shadowColor = rgba(z, isAct ? 0.85 : 0.04);
            ctx.shadowBlur  = isAct ? 12 : 1;
            ctx.fillText(ld.text, xRight, y + 5);
            ctx.restore();
        });

        // ── Live distance readout — centre-bottom, always visible ──────────
        var distPulse = az.name === 'red'
            ? 0.60 + 0.40 * Math.abs(Math.sin(ts * 0.007))
            : 1.0;
        var readY = areaBottom - 16;
        ctx.save();
        ctx.font        = 'bold 22px Arial, sans-serif';
        ctx.textAlign   = 'center';
        ctx.fillStyle   = rgba(az, distPulse);
        ctx.shadowColor = rgba(az, 0.90 * distPulse);
        ctx.shadowBlur  = 20;
        ctx.fillText(dist.toFixed(1) + ' m', cx, readY);
        ctx.restore();

        state.rafId = requestAnimationFrame(draw);
    }

    // ─── Activate / deactivate ────────────────────────────────────────────
    function activate() {
        state.active       = true;
        state.distance     = 9.0;
        state.speed        = 0.0;
        state.phase        = 0.0;
        state.lastTime     = null;
        state.lastBeepDist = 9.0;
        lastZoneName       = 'green';
        mountCanvas();
        startObserver();
        setStaticVisible(false);
        if (!state.rafId) state.rafId = requestAnimationFrame(draw);
    }
    function deactivate() {
        state.active = false;
        clearBeeps();
        lastZoneName = 'green';
        stopObserver();
        unmountCanvas();
        setStaticVisible(true);
    }

    // ─── NUI message listener ─────────────────────────────────────────────
    window.addEventListener('message', function (e) {
        var d = e.data;
        if (!d || !d.event) return;

        if (d.event === 'SetCameraRearView') {
            d.cameraRearView ? activate() : deactivate();
        }

        if (d.event === 'UpdateCameraDistance') {
            state.distance = Math.max(0.05, Math.min(9.0, d.distance     || 9.0));
            state.speed    = Math.max(0.0,  Math.min(30.0, d.reverseSpeed || 0.0));

            // ── Beep logic ──────────────────────────────────────────────
            var az       = activeZone(state.distance);
            var zoneChanged   = az.name !== lastZoneName;
            // Re-schedule beeps if zone changed OR distance moved more than
            // 0.25 m (so interval adjusts as the vehicle creeps closer).
            var distChanged   = Math.abs(state.distance - state.lastBeepDist) > 0.25;

            if (az.name === 'green') {
                if (lastZoneName !== 'green') clearBeeps();
            } else if (zoneChanged || distChanged) {
                scheduleBeeps(state.distance, az.name);
                state.lastBeepDist = state.distance;
            }
            lastZoneName = az.name;
        }
    });

    console.log('[RoadCarPlay] Camera overlay v5 (accurate zones + beep) active.');
})();
