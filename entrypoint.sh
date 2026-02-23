#!/bin/bash

# Выход при ошибке
set -e

echo "Применение миграций базы данных..."
python manage.py migrate --noinput

echo "Сбор статических файлов..."
python manage.py collectstatic --noinput --clear

echo "Создание суперпользователя (если не существует)..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    print('Создание суперпользователя admin...')
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
    print('Суперпользователь создан!')
else:
    print('Суперпользователь уже существует')
END

echo "Запуск сервера..."
exec "$@"
