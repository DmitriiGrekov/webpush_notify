# Django Push Notifications с Docker, Nginx и Let's Encrypt

Это Django приложение для отправки push-уведомлений, настроенное для запуска в Docker с nginx, автоматическим SSL сертификатом от Let's Encrypt и PostgreSQL.

## Требования

- Docker
- Docker Compose
- Доменное имя, указывающее на ваш сервер

## Быстрый старт

### 1. Клонирование и настройка

```bash
# Создайте .env файл из примера
cp .env.example .env

# Отредактируйте .env файл и укажите ваши настройки
nano .env
```

Обязательно измените следующие параметры в `.env`:
- `SECRET_KEY` - сгенерируйте новый секретный ключ
- `ALLOWED_HOSTS` - укажите ваш домен
- `POSTGRES_PASSWORD` - установите надежный пароль
- `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_ADMIN_EMAIL` - ваши VAPID ключи

### 2. Инициализация SSL сертификата

Перед первым запуском необходимо получить SSL сертификат от Let's Encrypt:

```bash
# Сделайте скрипт исполняемым
chmod +x init-letsencrypt.sh

# Запустите скрипт с вашим доменом и email
./init-letsencrypt.sh your-domain.com your-email@example.com
```

Этот скрипт:
- Создаст временный самоподписанный сертификат
- Запустит nginx
- Получит настоящий SSL сертификат от Let's Encrypt
- Перезагрузит nginx с новым сертификатом

### 3. Запуск приложения

После успешной инициализации SSL:

```bash
# Запуск всех сервисов
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Остановка сервисов
docker-compose down
```

### 4. Доступ к приложению

- Сайт: `https://your-domain.com`
- Админ-панель: `https://your-domain.com/admin`
  - Логин: `admin`
  - Пароль: `admin` (измените после первого входа!)

## Структура проекта

```
.
├── docker-compose.yml          # Конфигурация Docker Compose
├── Dockerfile                  # Dockerfile для Django приложения
├── entrypoint.sh              # Скрипт инициализации Django
├── init-letsencrypt.sh        # Скрипт получения SSL сертификата
├── requirements.txt           # Python зависимости
├── .env.example              # Пример файла переменных окружения
├── nginx/
│   └── conf.d/
│       └── default.conf      # Конфигурация nginx
├── pushsite/                 # Django проект
│   ├── settings.py          # Настройки Django
│   ├── urls.py
│   └── wsgi.py
└── notifications/            # Django приложение
    ├── models.py
    ├── views.py
    └── ...
```

## Сервисы Docker

### web (Django)
- Запускает Django приложение через Gunicorn
- Порт: 8000 (внутренний)
- Подключается к PostgreSQL

### db (PostgreSQL)
- База данных PostgreSQL 15
- Данные хранятся в Docker volume `postgres_data`

### nginx
- Reverse proxy для Django
- Обслуживает статические файлы
- Автоматический редирект HTTP → HTTPS
- Порты: 80, 443

### certbot
- Автоматическое обновление SSL сертификатов
- Проверка каждые 12 часов

## Управление

### Просмотр логов

```bash
# Все сервисы
docker-compose logs -f

# Конкретный сервис
docker-compose logs -f web
docker-compose logs -f nginx
docker-compose logs -f db
```

### Выполнение команд Django

```bash
# Создание миграций
docker-compose exec web python manage.py makemigrations

# Применение миграций
docker-compose exec web python manage.py migrate

# Создание суперпользователя
docker-compose exec web python manage.py createsuperuser

# Сбор статических файлов
docker-compose exec web python manage.py collectstatic
```

### Доступ к базе данных

```bash
# Подключение к PostgreSQL
docker-compose exec db psql -U pushsite_user -d pushsite
```

### Резервное копирование базы данных

```bash
# Создание бэкапа
docker-compose exec db pg_dump -U pushsite_user pushsite > backup.sql

# Восстановление из бэкапа
docker-compose exec -T db psql -U pushsite_user pushsite < backup.sql
```

## Обновление приложения

```bash
# Остановка сервисов
docker-compose down

# Получение обновлений
git pull

# Пересборка образов
docker-compose build

# Запуск с применением миграций
docker-compose up -d

# Проверка логов
docker-compose logs -f web
```

## Обновление SSL сертификата

Certbot автоматически обновляет сертификаты каждые 12 часов. Для ручного обновления:

```bash
docker-compose exec certbot certbot renew
docker-compose exec nginx nginx -s reload
```

## Безопасность

### Важные настройки безопасности:

1. **Измените пароли по умолчанию** в `.env`:
   - `SECRET_KEY`
   - `POSTGRES_PASSWORD`
   - Пароль администратора Django

2. **Настройте файрвол**:
   ```bash
   # Разрешить только HTTP, HTTPS и SSH
   ufw allow 22/tcp
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw enable
   ```

3. **Регулярно обновляйте зависимости**:
   ```bash
   pip list --outdated
   ```

4. **Мониторинг логов**:
   ```bash
   docker-compose logs -f nginx | grep -i error
   ```

## Решение проблем

### Проблема: Nginx не запускается

```bash
# Проверьте конфигурацию nginx
docker-compose exec nginx nginx -t

# Проверьте логи
docker-compose logs nginx
```

### Проблема: База данных недоступна

```bash
# Проверьте статус контейнера
docker-compose ps

# Проверьте логи PostgreSQL
docker-compose logs db

# Перезапустите базу данных
docker-compose restart db
```

### Проблема: SSL сертификат не работает

```bash
# Проверьте сертификаты
docker-compose exec certbot certbot certificates

# Переполучите сертификат
./init-letsencrypt.sh your-domain.com your-email@example.com
```

### Проблема: Статические файлы не загружаются

```bash
# Пересоберите статику
docker-compose exec web python manage.py collectstatic --clear --noinput

# Проверьте права доступа
docker-compose exec web ls -la /app/staticfiles
```

## Производительность

### Масштабирование Gunicorn workers

В `docker-compose.yml` измените количество workers:

```yaml
command: gunicorn pushsite.wsgi:application --bind 0.0.0.0:8000 --workers 5
```

Рекомендуемое количество: `(2 × количество CPU) + 1`

### Настройка PostgreSQL

Для production окружения рекомендуется настроить PostgreSQL параметры в `docker-compose.yml`:

```yaml
db:
  environment:
    - POSTGRES_INITDB_ARGS="-E UTF8 --locale=ru_RU.UTF-8"
  command: postgres -c shared_buffers=256MB -c max_connections=200
```

## Лицензия

MIT

## Поддержка

При возникновении проблем создайте issue в репозитории проекта.