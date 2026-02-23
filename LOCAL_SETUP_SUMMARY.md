# 🎉 Локальная разработка настроена!

Проект теперь можно запускать локально без Docker.

## 🚀 Быстрый старт

### Один скрипт для запуска:

**macOS/Linux:**
```bash
./run_local.sh
```

**Windows:**
```bash
run_local.bat
```

Скрипт автоматически:
- ✅ Создаст виртуальное окружение
- ✅ Установит зависимости
- ✅ Настроит базу данных SQLite
- ✅ Применит миграции
- ✅ Соберёт статические файлы
- ✅ Запустит сервер на http://localhost:8000

## 📚 Документация

1. **[QUICKSTART_LOCAL.md](QUICKSTART_LOCAL.md)** - Быстрый старт за 5 минут
2. **[LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)** - Полное руководство
3. **[CHANGELOG_LOCAL.md](CHANGELOG_LOCAL.md)** - Список всех изменений

## 🔑 Генерация VAPID ключей

Если нужны push-уведомления:

```bash
python generate_vapid_keys.py
```

Скопируйте вывод в файл `.env`

## 📁 Созданные файлы

### Скрипты
- `run_local.sh` - Запуск для Unix/Linux/macOS
- `run_local.bat` - Запуск для Windows
- `generate_vapid_keys.py` - Генератор VAPID ключей

### Конфигурация
- `.env.local.example` - Пример переменных окружения

### Документация
- `LOCAL_DEVELOPMENT.md` - Полное руководство
- `QUICKSTART_LOCAL.md` - Быстрый старт
- `GITIGNORE_TEMPLATE.md` - Рекомендации для .gitignore
- `CHANGELOG_LOCAL.md` - Список изменений

## 🔄 Переключение между режимами

### Локальная разработка
```bash
./run_local.sh
# Использует SQLite, DEBUG=True
```

### Production (Docker)
```bash
docker-compose up -d
# Использует PostgreSQL, HTTPS, Nginx
```

## ⚙️ Настройка .gitignore

**Важно!** Добавьте в `.gitignore`:

```gitignore
# Локальная разработка
env/
db.sqlite3
.env
private_key.pem
```

См. полный список в [GITIGNORE_TEMPLATE.md](GITIGNORE_TEMPLATE.md)

## 🎯 Что дальше?

1. Запустите проект: `./run_local.sh`
2. Откройте http://localhost:8000
3. Войдите в админку: http://localhost:8000/admin
4. Начните разработку!

## 💡 Полезные команды

```bash
# Активация виртуального окружения
source env/bin/activate  # macOS/Linux
env\Scripts\activate     # Windows

# Django команды
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py shell
python manage.py test

# Запуск на другом порту
python manage.py runserver 8001
```

## 🐛 Решение проблем

### Порт занят
```bash
python manage.py runserver 8001
```

### Ошибка с зависимостями
```bash
pip install -r requirements.txt --upgrade
```

### База данных повреждена
```bash
rm db.sqlite3
python manage.py migrate
```

## 📖 Подробная документация

Для детальной информации см. [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)

## 🐳 Production развертывание

Для production с Docker см. [README.md](README.md)

---

**Готово!** Теперь вы можете разрабатывать локально без Docker! 🎊