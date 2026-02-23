# Локальная разработка без Docker

Это руководство описывает, как запустить проект локально без использования Docker для разработки и тестирования.

## Требования

- Python 3.10 или выше
- pip (менеджер пакетов Python)
- Виртуальное окружение (venv или virtualenv)

## Быстрый старт

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd pushsite
```

### 2. Создание виртуального окружения

```bash
# Создание виртуального окружения
python3 -m venv env

# Активация виртуального окружения
# На macOS/Linux:
source env/bin/activate

# На Windows:
env\Scripts\activate
```

### 3. Установка зависимостей

```bash
pip install -r requirements.txt
```

### 4. Настройка переменных окружения

```bash
# Создайте .env файл для локальной разработки
cp .env.local.example .env
```

Отредактируйте `.env` файл:

```env
DEBUG=True
SECRET_KEY=your-local-secret-key-for-development
ALLOWED_HOSTS=localhost,127.0.0.1

# VAPID ключи для push уведомлений (опционально для локальной разработки)
VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=private_key.pem
VAPID_ADMIN_EMAIL=admin@localhost
```

**Примечание:** При локальной разработке проект автоматически использует SQLite вместо PostgreSQL.

### 5. Генерация VAPID ключей (опционально)

Если вам нужны push-уведомления для локальной разработки:

```bash
python generate_vapid_keys.py
```

Этот скрипт создаст файл `private_key.pem` и выведет публичный ключ для `.env` файла.

### 6. Применение миграций базы данных

```bash
python manage.py migrate
```

### 7. Создание суперпользователя

```bash
python manage.py createsuperuser
```

Следуйте инструкциям для создания администратора.

### 8. Сбор статических файлов

```bash
python manage.py collectstatic --noinput
```

### 9. Запуск сервера разработки

```bash
python manage.py runserver
```

Или используйте удобный скрипт:

```bash
# На macOS/Linux:
./run_local.sh

# На Windows:
run_local.bat
```

### 10. Доступ к приложению

- Сайт: http://localhost:8000
- Админ-панель: http://localhost:8000/admin

## Структура для локальной разработки

```
.
├── env/                      # Виртуальное окружение (не коммитится)
├── db.sqlite3               # База данных SQLite (не коммитится)
├── .env                     # Локальные переменные окружения (не коммитится)
├── .env.local.example       # Пример локальных переменных
├── manage.py                # Django management команды
├── requirements.txt         # Python зависимости
├── run_local.sh            # Скрипт запуска для Unix
├── run_local.bat           # Скрипт запуска для Windows
├── generate_vapid_keys.py  # Генератор VAPID ключей
└── LOCAL_DEVELOPMENT.md    # Эта документация
```

## Полезные команды для разработки

### Управление базой данных

```bash
# Создание новых миграций
python manage.py makemigrations

# Применение миграций
python manage.py migrate

# Откат миграций
python manage.py migrate notifications zero

# Просмотр SQL миграций
python manage.py sqlmigrate notifications 0001
```

### Работа с данными

```bash
# Загрузка тестовых данных
python manage.py loaddata fixtures/test_data.json

# Экспорт данных
python manage.py dumpdata notifications > backup.json

# Очистка базы данных
python manage.py flush
```

### Django shell

```bash
# Интерактивная консоль Python с Django
python manage.py shell

# Пример использования:
>>> from notifications.models import PushSubscription
>>> PushSubscription.objects.all()
```

### Тестирование

```bash
# Запуск всех тестов
python manage.py test

# Запуск тестов конкретного приложения
python manage.py test notifications

# Запуск с подробным выводом
python manage.py test --verbosity=2
```

### Статические файлы

```bash
# Сбор статических файлов
python manage.py collectstatic

# Очистка и пересбор
python manage.py collectstatic --clear --noinput

# Поиск статических файлов
python manage.py findstatic admin/css/base.css
```

## Отладка

### Django Debug Toolbar (опционально)

Для улучшенной отладки можно установить Django Debug Toolbar:

```bash
pip install django-debug-toolbar
```

Добавьте в `pushsite/settings.py` (только для локальной разработки):

```python
if DEBUG:
    INSTALLED_APPS += ['debug_toolbar']
    MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']
    INTERNAL_IPS = ['127.0.0.1']
```

### Логирование

Для просмотра SQL запросов добавьте в `pushsite/settings.py`:

```python
if DEBUG:
    LOGGING = {
        'version': 1,
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
            },
        },
        'loggers': {
            'django.db.backends': {
                'handlers': ['console'],
                'level': 'DEBUG',
            },
        },
    }
```

## Различия между локальной и production средой

| Параметр | Локально | Production (Docker) |
|----------|----------|---------------------|
| База данных | SQLite | PostgreSQL |
| DEBUG | True | False |
| HTTPS | Нет | Да (Let's Encrypt) |
| Веб-сервер | Django runserver | Gunicorn + Nginx |
| Статика | Django serves | Nginx serves |
| Переменные окружения | .env | Docker environment |

## Переход на production

Когда вы готовы развернуть на production:

1. Убедитесь, что все изменения закоммичены
2. Обновите `.env` файл на сервере с production настройками
3. Используйте Docker для развертывания (см. [README.md](README.md))

```bash
# На сервере
docker-compose build
docker-compose up -d
```

## Решение проблем

### Ошибка: "No module named 'psycopg2'"

Если вы не планируете использовать PostgreSQL локально, это нормально. Проект автоматически использует SQLite.

Если нужен PostgreSQL локально:

```bash
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# Установка psycopg2
pip install psycopg2-binary
```

### Ошибка: "VAPID keys not found"

Если push-уведомления не критичны для разработки, можно оставить VAPID ключи пустыми. Иначе:

```bash
python generate_vapid_keys.py
```

### Порт 8000 уже занят

```bash
# Используйте другой порт
python manage.py runserver 8001

# Или найдите процесс, использующий порт
# macOS/Linux:
lsof -i :8000

# Windows:
netstat -ano | findstr :8000
```

### Ошибки миграций

```bash
# Удалите базу данных и создайте заново
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

## Горячая перезагрузка

Django автоматически перезагружает сервер при изменении файлов. Если это не работает:

```bash
# Запустите с явным указанием
python manage.py runserver --noreload
```

## Работа с виртуальным окружением

```bash
# Деактивация виртуального окружения
deactivate

# Повторная активация
source env/bin/activate  # macOS/Linux
env\Scripts\activate     # Windows

# Обновление зависимостей
pip install -r requirements.txt --upgrade

# Экспорт зависимостей
pip freeze > requirements.txt
```

## Полезные ссылки

- [Django документация](https://docs.djangoproject.com/)
- [Django REST framework](https://www.django-rest-framework.org/)
- [Web Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API)
- [VAPID спецификация](https://datatracker.ietf.org/doc/html/rfc8292)

## Поддержка

Для production развертывания см. [README.md](README.md) и [QUICKSTART.md](QUICKSTART.md)