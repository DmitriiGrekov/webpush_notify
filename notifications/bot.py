import asyncio
import os
import sys
import django
from pathlib import Path

# Инициализация Django
# Определяем корневую директорию проекта (где находится manage.py)
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pushsite.settings')
django.setup()

from aiogram import Bot, Dispatcher, types
from aiogram.filters import CommandStart
from django.conf import settings
from asgiref.sync import sync_to_async
from notifications.models import TelegramSubscriber


bot = Bot(token=settings.TELEGRAM_BOT_TOKEN)
dp = Dispatcher()


@sync_to_async
def get_or_create_subscriber(chat_id: int, username: str):
    """Получить или создать подписчика в БД"""
    return TelegramSubscriber.objects.get_or_create(
        chat_id=chat_id,
        defaults={'username': username}
    )


@dp.message(CommandStart())
async def start(message: types.Message):
    chat_id = message.chat.id
    username = message.from_user.username if message.from_user else ''
    
    # Вызываем асинхронную обертку для работы с БД
    subscriber, created = await get_or_create_subscriber(chat_id, username or '')
    
    if created:
        await message.answer('✅ Вы подписаны на уведомления о протечке воды!')
    else:
        await message.answer('ℹ️ Вы уже подписаны на уведомления.')

@dp.message()
async def unknown(message: types.Message):
    await message.answer('Отправьте /start чтобы подписаться на уведомления.')

async def main():
    await dp.start_polling(bot)

if __name__ == '__main__':
    asyncio.run(main())