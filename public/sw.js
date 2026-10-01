/* Service worker sederhana Gamma One: cache shell aplikasi, fallback offline. */
const CACHE = 'gamma-one-v1';
const SHELL = ['/', '/manifest.webmanifest'];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET' || !request.url.startsWith(self.location.origin)) {
    return;
  }
  // Jangan cache API: selalu ke jaringan agar data absensi/keuangan segar.
  if (new URL(request.url).pathname.startsWith('/api/')) {
    return;
  }
  event.respondWith(
    caches.match(request).then(
      (cached) => cached || fetch(request).then((response) => {
        const copy = response.clone();
        caches.open(CACHE).then((cache) => cache.put(request, copy));
        return response;
      }).catch(() => caches.match('/'))
    )
  );
});
