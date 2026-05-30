importScripts('https://www.gstatic.com/firebasejs/9.18.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.18.0/firebase-messaging-compat.js');

// Configuración de Firebase por defecto (entorno DEV local para pruebas estelares)
const firebaseConfig = {
  apiKey: 'AIzaSyA0jbq8jf3N21ofh-yTuoBmDBXw7ZJHWdw',
  appId: '1:926192829506:web:74c80dd1b02d8697c9d9db',
  messagingSenderId: '926192829506',
  projectId: 'sudoku-arena-dev',
  authDomain: 'sudoku-arena-dev.firebaseapp.com',
  storageBucket: 'sudoku-arena-dev.firebasestorage.app',
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Manejar notificaciones push en segundo plano (Background / Pestaña cerrada)
messaging.onBackgroundMessage((payload) => {
  console.log('🔔 FCM Web SW: Recibido mensaje push en segundo plano: ', payload);

  const title = payload.notification ? payload.notification.title : 'Mensaje Estelar';
  const body = payload.notification ? payload.notification.body : '';

  // Opciones ultra-premium para la visualización del push nativo de la web
  const notificationOptions = {
    body: body,
    icon: '/favicon.png', // Icono por defecto de la app
    badge: '/favicon.png',
    data: payload.data,
  };

  return self.registration.showNotification(title, notificationOptions);
});

// Manejar el evento de click en la notificación web
self.addEventListener('notificationclick', (event) => {
  console.log('🔔 FCM Web SW: Click en notificación web: ', event.notification.data);
  event.notification.close();

  // Enfocar pestaña existente o abrir una nueva de Sudoku Arena
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (let i = 0; i < windowClients.length; i++) {
        const client = windowClients[i];
        if (client.url.indexOf(self.location.origin) !== -1 && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
