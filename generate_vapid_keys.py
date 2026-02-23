#!/usr/bin/env python3
"""
Скрипт для генерации VAPID ключей для Web Push уведомлений.
Использование: python generate_vapid_keys.py
"""

import base64
import sys

try:
    from py_vapid import Vapid
    from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat
except ImportError:
    print("❌ Ошибка: Необходимые библиотеки не установлены.")
    print("📦 Установите зависимости: pip install py-vapid cryptography")
    sys.exit(1)


def generate_vapid_keys():
    """Генерирует VAPID ключи для Web Push уведомлений."""
    
    print("🔐 Генерация VAPID ключей...")
    print()
    
    # Создание VAPID объекта
    vapid = Vapid()
    vapid.generate_keys()
    
    # Сохранение приватного ключа в файл
    private_key_file = 'private_key.pem'
    vapid.save_key(private_key_file)
    print(f"✅ Приватный ключ сохранен в файл: {private_key_file}")
    
    # Получение публичного ключа в формате base64url
    raw = vapid.private_key.public_key().public_bytes(
        Encoding.X962,
        PublicFormat.UncompressedPoint
    )
    public_key = base64.urlsafe_b64encode(raw).decode('utf-8').rstrip('=')
    
    print(f"✅ Публичный ключ сгенерирован (длина: {len(public_key)} символов)")
    print()
    
    # Вывод результатов
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 Добавьте следующие строки в ваш .env файл:")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    print(f"VAPID_PUBLIC_KEY={public_key}")
    print(f"VAPID_PRIVATE_KEY={private_key_file}")
    print("VAPID_ADMIN_EMAIL=admin@your-domain.com")
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    print("⚠️  ВАЖНО:")
    print("   1. Замените admin@your-domain.com на ваш реальный email")
    print("   2. Храните приватный ключ в безопасности")
    print("   3. Не коммитьте private_key.pem в git")
    print()
    
    # Проверка длины ключа
    if len(public_key) != 87:
        print("⚠️  ПРЕДУПРЕЖДЕНИЕ: Длина публичного ключа не равна 87 символам.")
        print(f"   Текущая длина: {len(public_key)}")
        print("   Это может вызвать проблемы с некоторыми браузерами.")
        print()
    
    return public_key, private_key_file


def main():
    """Главная функция."""
    try:
        generate_vapid_keys()
        print("✅ VAPID ключи успешно сгенерированы!")
        return 0
    except Exception as e:
        print(f"❌ Ошибка при генерации ключей: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())