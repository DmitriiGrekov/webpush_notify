#!/bin/bash

# Скрипт для запуска Django проекта локально без Docker
# Использование: ./run_local.sh

set -e

echo "🚀 Запуск Django проекта локально..."
echo ""

# Проверка наличия виртуального окружения
if [ ! -d "env" ]; then
    echo "⚠️  Виртуальное окружение не найдено."
    echo "📦 Создание виртуального окружения..."
    python3 -m venv env
    echo "✅ Виртуальное окружение создано"
    echo ""
fi

# Активация виртуального окружения
echo "🔧 Активация виртуального окружения..."
source env/bin/activate

# Проверка и установка зависимостей
echo "📚 Проверка зависимостей..."
pip3 install -r requirements.txt
echo "✅ Зависимости установлены"
echo ""

# Проверка наличия .env файла
if [ ! -f ".env" ]; then
    echo "⚠️  Файл .env не найден."
    if [ -f ".env.local.example" ]; then
        echo "📝 Копирование .env.local.example в .env..."
        cp .env.local.example .env
        echo "✅ Файл .env создан. Пожалуйста, отредактируйте его при необходимости."
    else
        echo "❌ Файл .env.local.example не найден. Создайте .env вручную."
        exit 1
    fi
    echo ""
fi

# Загрузка переменных окружения
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Применение миграций
echo "🗄️  Применение миграций базы данных..."
python manage.py migrate --noinput
echo "✅ Миграции применены"
echo ""

# Сбор статических файлов
echo "📦 Сбор статических файлов..."
python manage.py collectstatic --noinput --clear > /dev/null 2>&1
echo "✅ Статические файлы собраны"
echo ""

# Проверка наличия суперпользователя
echo "👤 Проверка суперпользователя..."
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); exit(0 if User.objects.filter(is_superuser=True).exists() else 1)" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠️  Суперпользователь не найден."
    echo "📝 Создайте суперпользователя для доступа к админ-панели:"
    echo "   python manage.py createsuperuser"
    echo ""
fi

# Запуск сервера разработки
echo "🌐 Запуск сервера разработки..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Сервер запущен!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 Сайт:         http://localhost:8000"
echo "🔐 Админ-панель: http://localhost:8000/admin"
echo ""
echo "💡 Для остановки нажмите Ctrl+C"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

python manage.py runserver