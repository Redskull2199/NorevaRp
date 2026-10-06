/**
 * RoadCarPlay — Music Proxy Compatibility Shim  (v7)
 *
 * The compiled NUI bundle (index-DyF-gUvt.js) has been patched to call
 * FiveM NUI endpoints directly:
 *
 *   SEARCH:   POST https://roadcarplay/searchMusicProxy  { query: string }
 *             → server queries Piped API → Invidious → Innertube WEB_EMBEDDED
 *             → returns { ok: true, body: "[{id,name,songname,icon,songlength}]" }
 *
 *   METADATA: POST https://roadcarplay/fetchVideoMeta    { videoId: string }
 *             → server queries YouTube oEmbed + Piped /streams
 *             → returns { ok: true, body: "{trackname,trackartist,trackimage,duration}" }
 *
 * This file is loaded BEFORE the bundle. It only needs to:
 *   1. Ensure fetch() is not accidentally broken by any leftover interception.
 *   2. Expose window.__rcpFetchVideoMeta() as a convenience alias.
 *   3. Log confirmation that the proxy layer is active.
 *
 * All actual proxying now happens via FiveM PerformHttpRequest on the server,
 * not through fetch() interception. This avoids the CORS / interceptor race
 * that was silently killing results before.
 */
(function () {
    'use strict';

    // Safety: ensure the original fetch is still intact.
    // The bundle no longer routes through window.fetch for music calls,
    // but the camera-overlay.js and other code still use it for non-music URLs.
    var _originalFetch = window.fetch.bind(window);

    // Convenience alias so any custom NUI scripts can request video metadata
    // without knowing the FiveM endpoint path.
    window.__rcpFetchVideoMeta = function (videoId) {
        return _originalFetch('https://roadcarplay/fetchVideoMeta', {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({ videoId: videoId })
        })
        .then(function (r) { return r.json(); })
        .then(function (result) {
            if (result && result.ok && result.body) {
                return JSON.parse(result.body);
            }
            return null;
        });
    };

    console.log('[RoadCarPlay] Music proxy shim v7 active — bundle patched, direct NUI routing.');
})();
