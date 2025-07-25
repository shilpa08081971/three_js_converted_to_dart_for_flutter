'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "a608670f03b8c13ec392e6a2944156e6",
"assets/AssetManifest.bin.json": "e34fe494fc0fc706bf3761c2eefe7a2f",
"assets/AssetManifest.json": "69c273524403d217cdcd733b85a45788",
"assets/assets/Planets/2k_stars_milky_way.jpg": "b5fc8274be63224b12252fd27a5bbb5f",
"assets/assets/Planets/deimosbump.jpg": "ee0cc4291e327014b9539858d6ef2f81",
"assets/assets/Planets/earthbump1k.jpg": "ef58250d6ada048d3064b277c7f8524f",
"assets/assets/Planets/earthcloudmap.jpg": "ddddcd03c30accdac77271bd7649a757",
"assets/assets/Planets/earthcloudmaptrans.jpg": "93ba672772c97207a33e6a7fcbf69c47",
"assets/assets/Planets/earthcloudmaptransInv.jpg": "966a303a3b55e6117fbae5e562e84ef0",
"assets/assets/Planets/earthlights1k.jpg": "cb1336ba51d72602307f25fcd94bfd6d",
"assets/assets/Planets/earthmap1k.jpg": "49c3b412cfa448ec819412fb3ca089d2",
"assets/assets/Planets/earthspec1k.jpg": "9a6b16e0637a055d0f890de691f77548",
"assets/assets/Planets/jupiter2_1k.jpg": "7436980574d4532e228930e1defea0bd",
"assets/assets/Planets/jupiterMoon.jpg": "cb106c7b95970fa7032d7fa71bd2e1c0",
"assets/assets/Planets/jupiterMoon2.jpg": "45a7cc6614cfb8b480edf2f2282085c1",
"assets/assets/Planets/marsbump1k.jpg": "f68f2bda183db9bda046f6530bf2de1e",
"assets/assets/Planets/marsmap1k.jpg": "56f226a559fd3807a5aab2e2efab8e24",
"assets/assets/Planets/mercurybump.jpg": "32995c7e3f2b7d55f30fa0cff4a830c1",
"assets/assets/Planets/mercurymap.jpg": "3a95b9218d50192d7be83add30e7f489",
"assets/assets/Planets/moonbump1k.jpg": "263245a67ccbfc16cd42f8318f7f003f",
"assets/assets/Planets/moonmap1k.jpg": "5b45b8a69b599925d0437e8c9fd1f950",
"assets/assets/Planets/neptunemap.jpg": "e77dd5920df878a66ba99c64ab136c42",
"assets/assets/Planets/phobosbump.jpg": "ba93fa7818635392ebc01bd7b41d13ac",
"assets/assets/Planets/plutobump1k.jpg": "634292d43428c4dd8e3916c3de674096",
"assets/assets/Planets/plutomap1k.jpg": "58971884cb0d18f2b30fd8d20580f7a6",
"assets/assets/Planets/saturnmap.jpg": "038ec3cf432f1a9ad5f876680d3de338",
"assets/assets/Planets/saturnringcolor.jpg": "8e80b3cf6d20013de762d29484a6c761",
"assets/assets/Planets/saturnringpattern.gif": "4080a68b0cb4974e17b03b5fc3d162bb",
"assets/assets/Planets/sunmap.jpg": "01e85bbfc4eafddf391d731616e6ab0d",
"assets/assets/Planets/uranusmap.jpg": "80153e46d25fe4d82c313fe23f0a3be4",
"assets/assets/Planets/uranusringcolour.jpg": "7ac8a9111cbcb4658d0bbfd700def054",
"assets/assets/Planets/uranusringtrans.gif": "64c73e05f7ee31e84483a37605dae8dd",
"assets/assets/Planets/venusbump.jpg": "9ca1ffe5f2f44382adb1123b81bc2f8e",
"assets/assets/Planets/venusmap.jpg": "a54a890656ffaf8aae589e23c879cd5f",
"assets/assets/stars/corona_bk.png": "22e4f8dc3a002dd504cf1b072616bd31",
"assets/assets/stars/corona_dn.png": "224f2fcffbdf678c52549666bdc0a844",
"assets/assets/stars/corona_ft.png": "7a5ee4ec7f7fe15223934cf5dcbb69f2",
"assets/assets/stars/corona_lf.png": "592cc57b1e3e1cb33397826cec755bb6",
"assets/assets/stars/corona_rt.png": "f11bfee3704ef1294d89d662a58e839d",
"assets/assets/stars/corona_up.png": "aaae37a134769efbd8e5e6e59eecb92b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "c0ad29d56cfe3890223c02da3c6e0448",
"assets/NOTICES": "e95d9d6209c0e90bc3f9d16a0a2537c9",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/three_js_controls/assets/joystick_background.png": "8c9aa78348b48e03f06bb97f74b819c9",
"assets/packages/three_js_controls/assets/joystick_knob.png": "bb0811554c35e7d74df6d80fb5ff5cd5",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "27361387bc24144b46a745f1afe92b50",
"canvaskit/canvaskit.wasm": "a37f2b0af4995714de856e21e882325c",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "f7c5e5502d577306fb6d530b1864ff86",
"canvaskit/chromium/canvaskit.wasm": "c054c2c892172308ca5a0bd1d7a7754b",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "9fe690d47b904d72c7d020bd303adf16",
"canvaskit/skwasm.wasm": "1c93738510f202d9ff44d36a4760126b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "6d54a61361fed2f567f586dad1aab676",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "c5c441226f89726952bb2b4ed13ba167",
"/": "c5c441226f89726952bb2b4ed13ba167",
"main.dart.js": "98268a1e5da3bce3f6a8c3292c70e3dd",
"manifest.json": "a0616e2de03c63216e217fa10810601d",
"version.json": "1a14e42892c9a14e1f50d5a98af6dcfe"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
