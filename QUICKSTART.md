# Быстрый запуск Django приложения с HTTPS

## Шаг 1: Подготовка сервера

Убедитесь, что у вас есть:
- Сервер с Ubuntu/Debian
- Доменное имя, указывающее на IP сервера
- Открыты порты 80 и 443

## Шаг 2: Установка Docker

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установка Docker Compose
sudo apt install docker-compose -y

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker
```

## Шаг 3: Настройка проекта

```bash
# Создание .env файла
cp .env.example .env

# Редактирование .env
nano .env
```

Генерация Vapid ключей
```
from py_vapid import Vapid
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat
import base64

vapid = Vapid()
vapid.generate_keys()
vapid.save_key('private_key.pem')

# Получаем raw байты публичного ключа (uncompressed point, 65 байт)
raw = vapid.private_key.public_key().public_bytes(
    Encoding.X962,
    PublicFormat.UncompressedPoint
)
public_key = base64.urlsafe_b64encode(raw).decode('utf-8').rstrip('=')

print("VAPID_PUBLIC_KEY =", repr(public_key))
print("Длина ключа:", len(public_key))  # должно быть 87
```

Измените следующие параметры:
```env
DEBUG=False
SECRET_KEY=ваш-секретный-ключ-минимум-50-символов
ALLOWED_HOSTS=ваш-домен.com,www.ваш-домен.com

POSTGRES_DB=pushsite
POSTGRES_USER=pushsite_user
POSTGRES_PASSWORD=надежный-пароль-для-базы-данных

VAPID_PUBLIC_KEY=ваш-vapid-публичный-ключ
VAPID_PRIVATE_KEY=ваш-vapid-приватный-ключ
VAPID_ADMIN_EMAIL=admin@ваш-домен.com
```

## Шаг 4: Получение SSL сертификата

```bash
# Сделать скрипт исполняемым
chmod +x init-letsencrypt.sh

# Запустить инициализацию SSL
./init-letsencrypt.sh ваш-домен.com admin@ваш-домен.com
```

Дождитесь завершения процесса (может занять 1-2 минуты).

## Шаг 5: Проверка работы

```bash
# Проверка статуса контейнеров
docker-compose ps

# Все контейнеры должны быть в статусе "Up"
```

Откройте браузер и перейдите на `https://ваш-домен.com`

## Шаг 6: Вход в админ-панель

1. Перейдите на `https://ваш-домен.com/admin`
2. Войдите с учетными данными:
   - Логин: `admin`
   - Пароль: `admin`
3. **ВАЖНО:** Сразу измените пароль администратора!

## Полезные команды

```bash
# Просмотр логов
docker-compose logs -f

# Перезапуск сервисов
docker-compose restart

# Остановка всех сервисов
docker-compose down

# Запуск сервисов
docker-compose up -d

# Обновление приложения
git pull
docker-compose build
docker-compose up -d
```

## Решение проблем

### Ошибка "Address already in use"
```bash
# Проверьте, что порты 80 и 443 свободны
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Остановите конфликтующие сервисы
sudo systemctl stop apache2
sudo systemctl stop nginx
```

### Ошибка SSL сертификата
```bash
# Проверьте DNS записи
nslookup ваш-домен.com

# Переполучите сертификат
docker-compose down
./init-letsencrypt.sh ваш-домен.com admin@ваш-домен.com
```

### База данных не запускается
```bash
# Проверьте логи
docker-compose logs db

# Пересоздайте контейнер
docker-compose down
docker volume rm pushsite_postgres_data
docker-compose up -d
```

## Безопасность

После запуска обязательно:

1. Измените пароль администратора Django
2. Настройте файрвол:
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```
3. Настройте регулярные бэкапы базы данных
4. Мониторьте логи на наличие ошибок

## Поддержка

Подробная документация: [README.md](README.md)