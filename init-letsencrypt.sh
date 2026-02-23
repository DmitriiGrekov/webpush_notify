#!/bin/bash

# Скрипт для первоначальной настройки Let's Encrypt SSL сертификатов
# Использование: ./init-letsencrypt.sh your-domain.com your-email@example.com

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: ./init-letsencrypt.sh <domain> <email>"
    echo "Пример: ./init-letsencrypt.sh example.com admin@example.com"
    exit 1
fi

domains=($1)
email="$2"
rsa_key_size=4096
data_path="./certbot"
staging=0 # Установите в 1 для тестирования

echo "### Подготовка директорий для $domains ..."

if [ -d "$data_path" ]; then
  read -p "Существующие данные найдены для $domains. Продолжить и заменить? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Загрузка рекомендуемых TLS параметров ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Создание временного самоподписанного сертификата для $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Обновление конфигурации nginx с доменом $domains ..."
sed -i.bak "s/your-domain.com/$domains/g" nginx/conf.d/default.conf
echo

echo "### Запуск nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Удаление временного сертификата для $domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Запрос Let's Encrypt сертификата для $domains ..."

# Выбор между staging и production сертификатом
case "$staging" in
  1) staging_arg="--staging" ;;
  *) staging_arg="" ;;
esac

# Включение HTTPS редиректа в nginx конфигурации
docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    --email $email \
    -d $domains \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal \
    --non-interactive" certbot
echo

echo "### Перезагрузка nginx ..."
docker-compose exec nginx nginx -s reload

echo "### Готово! SSL сертификат успешно установлен для $domains"