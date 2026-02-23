# Рекомендуемые настройки .gitignore

Добавьте следующие строки в ваш `.gitignore` файл для корректной работы с локальной разработкой:

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python

# Virtual Environment
env/
venv/
ENV/
env.bak/
venv.bak/

# Django
*.log
db.sqlite3
db.sqlite3-journal
/media
/staticfiles

# Environment variables
.env
.env.local

# VAPID keys
private_key.pem
private_key_ec.pem

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# PyInstaller
*.manifest
*.spec

# Unit test / coverage reports
htmlcov/
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# mypy
.mypy_cache/
.dmypy.json
dmypy.json
```

## Важные файлы для исключения

Обязательно добавьте в `.gitignore`:

1. **env/** - виртуальное окружение Python
2. **db.sqlite3** - локальная база данных SQLite
3. **.env** - файл с переменными окружения
4. **private_key.pem** - приватный VAPID ключ
5. **staticfiles/** - собранные статические файлы

## Файлы, которые ДОЛЖНЫ быть в репозитории

Следующие файлы должны быть закоммичены:

- `.env.example` - пример переменных окружения для production
- `.env.local.example` - пример переменных для локальной разработки
- `requirements.txt` - зависимости Python
- `run_local.sh` - скрипт запуска для Unix
- `run_local.bat` - скрипт запуска для Windows
- `generate_vapid_keys.py` - генератор VAPID ключей
- `LOCAL_DEVELOPMENT.md` - документация по локальной разработке