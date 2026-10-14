/* Gamma One: HTML selalu dari jaringan (agar update langsung tayang),
   aset berversi di-cache (nama berkas mengandung hash, aman), API tak di-cache. */
const CACHE = 'gamma-one-v2';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.add('/manifest.webmanifest').catch(() => {}))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

function isImmutableAsset(pathname) {
  return pathname.startsWith('/build/assets/') || pathname.startsWith('/images/') || pathname.endsWith('.woff2') || pathname.endsWith('.woff');
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET' || !request.url.startsWith(self.location.origin)) {
    return;
  }
  const url = new URL(request.url);
  if (url.pathname.startsWith('/api/')) {
    return;
  }
  // Navigasi/halaman: jaringan dulu, cache hanya saat offline.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
          return response;
        })
        .catch(() => caches.match(request).then((cached) => cached || caches.match('/')))
    );
    return;
  }
  // Aset berversi: cache dulu (aman karena nama berkas berubah tiap build).
  if (isImmutableAsset(url.pathname)) {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request).then((response) => {
        const copy = response.clone();
        caches.open(CACHE).then((cache) => cache.put(request, copy));
        return response;
      }))
    );
  }
});
