FROM python:3.11-slim

# Установка переменных окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Установка рабочей директории
WORKDIR /app

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    postgresql-client \
    gcc \
    python3-dev \
    musl-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Копирование requirements.txt
COPY requirements.txt /app/

# Установка Python зависимостей
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# Копирование проекта
COPY . /app/

# Копирование и установка прав на entrypoint скрипт
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Создание директорий для статики и медиа
RUN mkdir -p /app/staticfiles /app/media

# Запуск entrypoint скрипта
ENTRYPOINT ["/app/entrypoint.sh"]
