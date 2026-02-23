from django.contrib import admin
from .models import PushSubcsription, TelegramSubscriber

admin.site.register(PushSubcsription)
admin.site.register(TelegramSubscriber)