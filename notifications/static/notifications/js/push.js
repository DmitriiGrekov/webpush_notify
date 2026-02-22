const VAPID_PUBLIC_KEY = document.querySelector('[data-vapid-key]').dataset.vapidKey;

// Конвертация base64 → Uint8Array (нужно для браузера)
function urlB64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
    const rawData = atob(base64);
    return new Uint8Array([...rawData].map(c => c.charCodeAt(0)));
}

async function registerServiceWorker() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
        alert('Ваш браузер не поддерживает push-уведомления');
        return null;
    }
    return await navigator.serviceWorker.register('/static/notifications/js/sw.js');
}

async function subscribeToPush() {
    const registration = await registerServiceWorker();
    if (!registration) return;

    const permission = await Notification.requestPermission();
    if (permission !== 'granted') {
        alert('Разрешение на уведомления отклонено');
        return;
    }

    const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlB64ToUint8Array(VAPID_PUBLIC_KEY)
    });

    // Отправляем подписку на сервер
    await fetch('/subscribe/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(subscription)
    });

    console.log('Подписка оформлена!');
    document.getElementById('status').textContent = '✅ Вы подписаны на уведомления';
}

async function unsubscribeFromPush() {
    const registration = await navigator.serviceWorker.getRegistration();
    if (!registration) return;

    const subscription = await registration.pushManager.getSubscription();
    if (!subscription) return;

    await fetch('/unsubscribe/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ endpoint: subscription.endpoint })
    });

    await subscription.unsubscribe();
    document.getElementById('status').textContent = '❌ Вы отписались от уведомлений';
}

document.getElementById('btn-subscribe').addEventListener('click', subscribeToPush);
document.getElementById('btn-unsubscribe').addEventListener('click', unsubscribeFromPush);