from django.shortcuts import render
from webpush import send_user_notification
from django.contrib.auth.models import User
from django.http import HttpResponse

def index(request):
    return render(request, "index.html")

def send_push(request):
    user = User.objects.first()  # для демо
    payload = {
        "title": "Привет 👋",
        "body": "Это push из Django"
    }
    send_user_notification(user=user, payload=payload)
    return HttpResponse("Push отправлен ✅")