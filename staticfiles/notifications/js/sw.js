// Service Worker — перехватывает push-события от сервера
self.addEventListener('push', function (event) {
    const data = event.data ? event.data.json() : {};
    const title = data.title || 'Уведомление';
    const options = {
        body: data.message || '',
        icon: '/static/notifications/img/icon.png',  // опционально
        badge: '/static/notifications/img/badge.png',
        data: { url: data.url || '/' }
    };
    event.waitUntil(self.registration.showNotification(title, options));
});

// Клик по уведомлению — открывает URL
self.addEventListener('notificationclick', function (event) {
    event.notification.close();
    event.waitUntil(clients.openWindow(event.notification.data.url));
});