from django.db import models

class PushSubcsription(models.Model):
    endpoint = models.URLField(max_length=500, unique=True)
    p256dh = models.CharField(max_length=200) # ключ шифрования
    auth = models.CharField(max_length=100) # токен аутентификации
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Subcription {self.id}'
