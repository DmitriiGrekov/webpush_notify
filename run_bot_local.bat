@echo off
REM Скрипт для запуска Telegram бота локально без Docker (Windows)
REM Использование: run_bot_local.bat

setlocal enabledelayedexpansion

echo.
echo 🤖 Запуск Telegram бота локально...
echo.

REM Проверка наличия виртуального окружения
if not exist "env\" (
    echo ⚠️  Виртуальное окружение не найдено.
    echo 📦 Создание виртуального окружения...
    python -m venv env
    if errorlevel 1 (
        echo ❌ Ошибка создания виртуального окружения
        pause
        exit /b 1
    )
    echo ✅ Виртуальное окружение создано
    echo.
)

REM Активация виртуального окружения
echo 🔧 Активация виртуального окружения...
call env\Scripts\activate.bat
if errorlevel 1 (
    echo ❌ Ошибка активации виртуального окружения
    pause
    exit /b 1
)

REM Проверка и установка зависимостей
echo 📚 Проверка зависимостей...
pip install -q -r requirements.txt
if errorlevel 1 (
    echo ⚠️  Ошибка установки зависимостей
)
echo ✅ Зависимости установлены
echo.

REM Проверка наличия .env файла
if not exist ".env" (
    echo ⚠️  Файл .env не найден.
    if exist ".env.local.example" (
        echo 📝 Копирование .env.local.example в .env...
        copy .env.local.example .env >nul
        echo ✅ Файл .env создан. Пожалуйста, отредактируйте его при необходимости.
    ) else (
        echo ❌ Файл .env.local.example не найден. Создайте .env вручную.
        pause
        exit /b 1
    )
    echo.
)

REM Применение миграций (если нужно)
echo 🗄️  Проверка миграций базы данных...
python manage.py migrate --noinput
if errorlevel 1 (
    echo ⚠️  Ошибка применения миграций
)
echo ✅ Миграции применены
echo.

REM Запуск бота
echo 🤖 Запуск Telegram бота...
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ✨ Telegram бот запущен!
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 💡 Для остановки нажмите Ctrl+C
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

python notifications\bot.py

endlocal