@echo off
REM Скрипт для запуска Django проекта локально без Docker (Windows)
REM Использование: run_local.bat

setlocal enabledelayedexpansion

echo.
echo 🚀 Запуск Django проекта локально...
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

REM Применение миграций
echo 🗄️  Применение миграций базы данных...
python manage.py migrate --noinput
if errorlevel 1 (
    echo ⚠️  Ошибка применения миграций
)
echo ✅ Миграции применены
echo.

REM Сбор статических файлов
echo 📦 Сбор статических файлов...
python manage.py collectstatic --noinput --clear >nul 2>&1
echo ✅ Статические файлы собраны
echo.

REM Проверка наличия суперпользователя
echo 👤 Проверка суперпользователя...
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); exit(0 if User.objects.filter(is_superuser=True).exists() else 1)" 2>nul
if errorlevel 1 (
    echo ⚠️  Суперпользователь не найден.
    echo 📝 Создайте суперпользователя для доступа к админ-панели:
    echo    python manage.py createsuperuser
    echo.
)

REM Запуск сервера разработки
echo 🌐 Запуск сервера разработки...
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ✨ Сервер запущен!
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 🔗 Сайт:         http://localhost:8000
echo 🔐 Админ-панель: http://localhost:8000/admin
echo.
echo 💡 Для остановки нажмите Ctrl+C
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

python manage.py runserver

endlocal