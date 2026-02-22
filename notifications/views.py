import json
from django.conf import settings
from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from pywebpush import webpush, WebPushException
from .models import PushSubcsription


def index(request):
    return render(request, 'notifications/index.html', {'vapid_public_key': settings.VAPID_PUBLIC_KEY})


@csrf_exempt
def subscribe(request):
    """Сохраняет подписку браузера"""
    if request.method == "POST":
        data = json.loads(request.body)
        PushSubcsription.objects.update_or_create(
            endpoint=data['endpoint'],
            defaults={
                'p256dh': data['keys']['p256dh'],
                'auth': data['keys']['auth'],
            }
        )
        return JsonResponse({"status": "subscribed"})
    return JsonResponse({"error": "POST required"}, status=405)


@csrf_exempt
def unsubscribe(request):
    """Удаляет подписку"""
    if request.method == 'POST':
        data = json.loads(request.body)
        PushSubcsription.objects.filter(endpoint=data['enpoint']).delete()
        return JsonResponse({'status': 'unsubscribed'})


@csrf_exempt
def send_notification(request):
    """Отправляет уведомление всем подписчикам."""
    if request.method == 'POST':
        title = request.POST.get('title', 'Уведомление')
        message = request.POST.get('message', '')
        payload = json.dumps({'title': title, 'message': message})
        subscriptions = PushSubcsription.objects.all()
        results = {'sent': 0, 'failed': 0}

        for sub in subscriptions:
            try:
                webpush(
                    subscription_info={
                        'endpoint': sub.endpoint,
                        'keys': {'p256dh': sub.p256dh, 'auth': sub.auth}
                    },
                    data=payload,
                    vapid_private_key=settings.VAPID_PRIVATE_KEY,
                    vapid_claims={
                        'sub': f'mailto:{settings.VAPID_ADMIN_EMAIL}'
                    }
                )
                results['sent'] += 1
            except WebPushException as e:
                results['failed'] += 1
                # если подписка устарела - удаляем
                if e.response and e.response.status_code == 410:
                    sub.delete()
        return JsonReponse(results)
    return render(request, 'notifications/send.html')
