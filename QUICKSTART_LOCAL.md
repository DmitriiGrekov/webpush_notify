# 🚀 Быстрый старт локальной разработки

Это краткое руководство для запуска проекта локально без Docker за 5 минут.

## Шаг 1: Установка зависимостей

```bash
# Создание виртуального окружения
python3 -m venv env

# Активация (macOS/Linux)
source env/bin/activate

# Активация (Windows)
env\Scripts\activate

# Установка зависимостей
pip install -r requirements.txt
```

## Шаг 2: Настройка окружения

```bash
# Копирование примера .env
cp .env.local.example .env

# Генерация VAPID ключей (опционально)
python generate_vapid_keys.py
```

## Шаг 3: Инициализация базы данных

```bash
# Применение миграций
python manage.py migrate

# Создание суперпользователя
python manage.py createsuperuser

# Сбор статических файлов
python manage.py collectstatic --noinput
```

## Шаг 4: Запуск сервера

```bash
# Запуск сервера разработки
python manage.py runserver
```

Или используйте готовый скрипт:

```bash
# macOS/Linux
./run_local.sh

# Windows
run_local.bat
```

## Готово! 🎉

Откройте браузер:
- **Сайт:** http://localhost:8000
- **Админка:** http://localhost:8000/admin

## Полезные команды

```bash
# Создание новых миграций
python manage.py makemigrations

# Применение миграций
python manage.py migrate

# Django shell
python manage.py shell

# Запуск тестов
python manage.py test
```

## Решение проблем

### Порт 8000 занят

```bash
# Используйте другой порт
python manage.py runserver 8001
```

### Ошибка с зависимостями

```bash
# Переустановите зависимости
pip install -r requirements.txt --upgrade
```

### База данных повреждена

```bash
# Удалите и пересоздайте
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

## Подробная документация

📖 См. [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md) для полной документации

## Production развертывание

🐳 Для production с Docker см. [README.md](README.md)