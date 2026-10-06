/**
 * RoadCarPlay — Music Fix Override  (v2)
 *
 * Strategy: instead of reimplementing NUI calls, we find and reuse
 * ctx._playById which already correctly routes to ae.playMusic or
 * ae.playMusicPlaylist. We only replace the broken DECISION logic
 * (shuffle / repeat / sequential) around that existing call.
 *
 * Fixes:
 *  1. NEXT/PREV SILENT  — nextSongEx/prevSongEx had the right intent
 *                         but _isPlaylistMode read playlist membership
 *                         which caused wrong routing. Patched on ctx.
 *
 *  2. SHUFFLE           — store.shuffle was ignored in auto-advance
 *                         (onmusicTrackEnded → store.nextSong). Fixed.
 *
 *  3. REPEAT MODES      — store.nextSong ignored store.repeat. Fixed.
 *
 *  4. AUTO-ADVANCE      — store.nextSong now respects shuffle + repeat.
 */
(function () {
  'use strict';

  var _ctx = null; /* cached MusicBar ctx */

  function getStore() {
    try {
      return document.querySelector('#app').__vue_app__
             .config.globalProperties.$pinia._s.get('music');
    } catch (_) { return null; }
  }

  /* ── Decide which song ID to play next ─────────────────────────── */
  function resolveNext(store) {
    var songs   = store.currentSongs;
    var repeat  = store.repeat  || 0;   /* 0=off  1=all  2=one */
    var shuffle = store.shuffle || false;
    var current = store.currentPlaying;

    if (!songs || !songs.length) return null;

    if (repeat === 2 && current != null) return current;   /* repeat-one */

    if (shuffle && songs.length > 1) {
      var pool = songs.filter(function (s) { return s.id != current; });
      var arr  = pool.length ? pool : songs;
      return arr[Math.floor(Math.random() * arr.length)].id;
    }

    var idx = songs.findIndex(function (s) { return s.id == current; });
    if (repeat === 1) return songs[(idx + 1) % songs.length].id; /* wrap */
    if (idx >= 0 && idx + 1 < songs.length) return songs[idx + 1].id;
    return null; /* last song + no repeat → stop */
  }

  function resolvePrev(store) {
    var songs   = store.currentSongs;
    var repeat  = store.repeat  || 0;
    var current = store.currentPlaying;

    if (!songs || !songs.length) return null;
    if (repeat === 2 && current != null) return current;

    var idx  = songs.findIndex(function (s) { return s.id == current; });
    var prev = idx > 0 ? idx - 1 : songs.length - 1;
    return songs[prev].id;
  }

  /* ── Route through ctx._playById (calls ae.playMusic / ae.playMusicPlaylist) */
  function getPlayById() {
    if (_ctx && typeof _ctx._playById === 'function') return _ctx._playById.bind(_ctx);
    var el = document.querySelector('.phone-music-bar');
    if (el && el.__vueParentComponent) {
      var ctx = el.__vueParentComponent.ctx;
      if (ctx && typeof ctx._playById === 'function') {
        _ctx = ctx;
        return ctx._playById.bind(ctx);
      }
    }
    return null;
  }

  function playNext() {
    var store = getStore();
    if (!store) return;
    var id = resolveNext(store);
    if (id == null) return;
    var fn = getPlayById();
    if (fn) fn(id);
  }

  function playPrev() {
    var store = getStore();
    if (!store) return;
    var id = resolvePrev(store);
    if (id == null) return;
    var fn = getPlayById();
    if (fn) fn(id);
  }

  /* ── Patch Pinia store (fixes auto-advance when song ends) ─────── */
  function patchStore() {
    var store = getStore();
    if (!store || store._rcpPatched) return;
    store._rcpPatched = true;
    store.nextSong = function () { playNext(); };
    store.previousSong = function () { playPrev(); };
    console.log('[RCP-Fix] store patched');
  }

  /* ── Patch MusicBar component ctx ───────────────────────────────── */
  function patchCtx() {
    var el = document.querySelector('.phone-music-bar');
    if (!el || !el.__vueParentComponent) return;

    var inst = el.__vueParentComponent;
    var ctx  = inst.ctx;
    if (!ctx || typeof ctx._playById !== 'function') return;
    if (inst._rcpCtxPatched) { _ctx = ctx; return; }

    inst._rcpCtxPatched = true;
    _ctx = ctx;

    ctx.nextSongEx = function () { playNext(); };
    ctx.prevSongEx = function () { playPrev(); };
    ctx._isPlaylistMode = function () {
      var store = getStore();
      return !!(store && store._playlistMode);
    };

    console.log('[RCP-Fix] ctx patched');
  }

  /* ── Polling: handles deferred mount + route-change remounts ────── */
  function poll() {
    patchStore();
    patchCtx();
  }

  setInterval(poll, 1500);
  setTimeout(poll, 800);

  window.__rcpFix = { playNext: playNext, playPrev: playPrev, getStore: getStore };
  console.log('[RCP-Fix] v2 loaded');
})();
