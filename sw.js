importScripts(
    'https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js'
  );

workbox.precaching.precacheAndRoute([
    { url: "./static/bg-ira.jpg", revision: null }, 
    { url: "./static/bg-avareza.jpg", revision: null }, 
    { url: "./static/bg-luxuria.jpg", revision: null }, 
    { url: "./static/bg-gula.jpg", revision: null }, 
    { url: "./static/bg-economia.jpg", revision: null }, 
    { url: "./static/bg-racismo.jpg", revision: null }, 
    { url: "./static/bg-intolerancia.jpg", revision: null }, 
    { url: "./static/bg-imigrantes.jpg", revision: null }, 
    { url: "./static/bg-lgbt.jpg", revision: null }, 
    { url: "./static/bg-ditadura.jpg", revision: null }, 
    { url: "./static/bg-presos.jpg", revision: null },     
]);