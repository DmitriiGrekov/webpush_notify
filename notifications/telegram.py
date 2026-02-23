import asyncio
from aiogram import Bot
from aiogram.exceptions import TelegramForbiddenError, TelegramBadRequest
from django.conf import settings
from asgiref.sync import sync_to_async
from .models import TelegramSubscriber

@sync_to_async
def _get_subscribers():
    return list(TelegramSubscriber.objects.all())

@sync_to_async
def _delete_subscriber(subscriber):
    subscriber.delete()

async def _send_all(text: str):
    bot = Bot(token=settings.TELEGRAM_BOT_TOKEN)
    # Получаем подписчиков асинхронно
    subscribers = await _get_subscribers()
    results = {'sent': 0, 'failed': 0}

    async with bot:
        for sub in subscribers:
            try:
                await bot.send_message(chat_id=sub.chat_id, text=text, parse_mode='HTML')
                results['sent'] += 1
            except TelegramForbiddenError:
                # пользователь заблокировал бота
                await _delete_subscriber(sub)
                results['failed'] += 1
            except TelegramBadRequest:
                results['failed'] += 1

    return results

def send_telegram_message(text: str):
    return asyncio.run(_send_all(text))