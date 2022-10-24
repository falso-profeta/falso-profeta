importScripts(
    'https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js'
  );

workbox.precaching.precacheAndRoute([
    { url: "./static/bg-amor.jpg", revision: null },
    { url: "./static/bg-corrupcao.jpg", revision: null },
    { url: "./static/bg-ditadura.jpg", revision: null },
    { url: "./static/bg-ganancia.jpg", revision: null },
    { url: "./static/bg-imigrantes.jpg", revision: null },
    { url: "./static/bg-intolerancia.jpg", revision: null },
    { url: "./static/bg-presos.jpg", revision: null },
    { url: "./static/bg-racismo.jpg", revision: null },
    { url: "./static/bg-trabalho.jpg", revision: null },
    { url: "./static/bg-violencia.jpg", revision: null },
]);