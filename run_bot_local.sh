#!/bin/bash

# Скрипт для запуска Telegram бота локально без Docker
# Использование: ./run_bot_local.sh

set -e

echo "🤖 Запуск Telegram бота локально..."
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

# Проверка наличия TELEGRAM_BOT_TOKEN
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "❌ TELEGRAM_BOT_TOKEN не установлен в .env файле"
    echo "📝 Добавьте TELEGRAM_BOT_TOKEN=ваш_токен в файл .env"
    exit 1
fi

# Применение миграций (если нужно)
echo "🗄️  Проверка миграций базы данных..."
python manage.py migrate --noinput
echo "✅ Миграции применены"
echo ""

# Запуск бота
echo "🤖 Запуск Telegram бота..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Telegram бот запущен!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Для остановки нажмите Ctrl+C"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

python notifications/bot.py