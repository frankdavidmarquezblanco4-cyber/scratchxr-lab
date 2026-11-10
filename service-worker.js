/* SCRATCHXR LAB · PWA offline cache */
'use strict';

const CACHE_NAME = 'scratchxr-offline-v22';
const APP_SHELL = [
  './',
  './index.html',
  './manifest.webmanifest',
  './assets/pwa/icon-192.png',
  './assets/pwa/icon-512.png',
  './assets/pwa/icon-maskable-512.png',
  './assets/models/scratch-cat.glb',
  './assets/vendor/model-viewer-4.0.0.min.js',
  './assets/vendor/aframe-1.7.0.min.js',
  './assets/vendor/aframe/fonts/Roboto-msdf.json',
  './assets/vendor/aframe/fonts/Roboto-msdf.png',
  './assets/vendor/mediapipe/vision_bundle.mjs',
  './assets/vendor/mediapipe/hand_landmarker.task',
  './assets/vendor/mediapipe/wasm/vision_wasm_internal.js',
  './assets/vendor/mediapipe/wasm/vision_wasm_internal.wasm',
  './assets/vendor/mediapipe/wasm/vision_wasm_nosimd_internal.js',
  './assets/vendor/mediapipe/wasm/vision_wasm_nosimd_internal.wasm'
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll(APP_SHELL);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.filter(name => name.startsWith('scratchxr-offline-') && name !== CACHE_NAME).map(name => caches.delete(name)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  // Do not cache external APIs, authentication traffic, or third-party responses.
  if (url.origin !== self.location.origin) return;

  // Mission audio checks use HEAD first. If its GET was previously played and
  // cached, synthesize a successful HEAD response while offline.
  if (request.method === 'HEAD') {
    if (!url.pathname.includes('/assets/audio/')) return;
    event.respondWith((async () => {
      const cache = await caches.open(CACHE_NAME);
      const cached = await cache.match(new Request(url.href, { method: 'GET' }), { ignoreVary: true });
      if (cached) return new Response(null, { status: cached.status, statusText: cached.statusText, headers: cached.headers });
      try { return await fetch(request); }
      catch (_) { return new Response(null, { status: 504, statusText: 'Offline' }); }
    })());
    return;
  }
  if (request.method !== 'GET') return;

  if (request.mode === 'navigate') {
    event.respondWith((async () => {
      const cache = await caches.open(CACHE_NAME);
      try {
        const response = await fetch(request);
        if (response.ok) await cache.put(request, response.clone());
        return response;
      } catch (_) {
        return (await cache.match(request)) || (await cache.match(new URL('./index.html', self.registration.scope).href)) || new Response('SCRATCHXR LAB no está disponible sin conexión todavía. Abre la aplicación una vez con internet para preparar el modo offline.', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
      }
    })());
    return;
  }

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    const isMissionAudio = url.pathname.includes('/assets/audio/');
    const audioCacheKey = isMissionAudio ? new Request(url.href, { method: 'GET' }) : request;
    const cached = await cache.match(isMissionAudio ? audioCacheKey : request, isMissionAudio ? { ignoreVary: true } : undefined);
    if (cached) return cached;
    try {
      const response = await fetch(request);
      if (isMissionAudio && response.status === 206) {
        // Browsers may request only a byte range for audio playback. Keep
        // serving that response, while separately caching the complete file.
        try {
          const full = await fetch(new Request(url.href, { method: 'GET', cache: 'no-store' }));
          if (full.status === 200 && full.type === 'basic') await cache.put(audioCacheKey, full.clone());
        } catch (_) { /* The current online playback still works; offline fallback remains available. */ }
      } else if (response.status === 200 && response.type === 'basic') {
        try { await cache.put(isMissionAudio ? audioCacheKey : request, response.clone()); }
        catch (_) { /* A cache quota/unsupported response must not break online playback. */ }
      }
      return response;
    } catch (_) {
      return new Response('Este recurso no se ha descargado en este dispositivo todavía.', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
    }
  })());
});
