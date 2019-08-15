'use strict';


const HHUB_CACHE_NAME = 'hhub-static-cache-v2';

// CODELAB: Add list of files to cache here.
const FILES_TO_CACHE = [
    '/offline.html',
    '/img/logo.png', 
    '/hhub/customer-login.html',
    '/hhub/vendor-login.html',
    '/img/intro-bg.jpg',
    '/css/style.css',
    '/css/bootstrap.min.css',
    '/hhub/dodcustordersdata'
];

self.addEventListener('install', (evt) => {
  console.log('[ServiceWorker] Install');
  // CODELAB: Precache static resources here.
    evt.waitUntil(
	caches.open(HHUB_CACHE_NAME).then((cache) => {
	    console.log('[ServiceWorker] Pre-caching offline page');
	    return cache.addAll(FILES_TO_CACHE);
	})
    );
    self.skipWaiting();
});

self.addEventListener('activate', (evt) => {
  console.log('[ServiceWorker] Activate');
  // CODELAB: Remove previous cached data from disk.
    evt.waitUntil(
	caches.keys().then((keyList) => {
	    return Promise.all(keyList.map((key) => {
		if (key !== HHUB_CACHE_NAME) {
		    console.log('[ServiceWorker] Removing old cache', key);
		    return caches.delete(key);
		}
	    }));
	})
    );
    self.clients.claim();
});

self.addEventListener('fetch', (evt) => {
  console.log('[ServiceWorker] Fetch', evt.request.url);
  // CODELAB: Add fetch event handler here.
if (evt.request.mode !== 'navigate') {
  // Not a page navigation, bail.
  return;
}
evt.respondWith(
    fetch(evt.request)
        .catch(() => {
          return caches.open(HHUB_CACHE_NAME)
              .then((cache) => {
                return cache.match('offline.html');
              });
        })
);

});
