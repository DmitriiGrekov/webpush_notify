from django.urls import path
from . import views


urlpatterns = [
    path('', views.index, name='index'),
    path('subscribe/', views.subscribe, name='subscribe'),
    path('unsubscribe/', views.unsubscribe, name='unsubscribe'),
    path('send-notification/', views.send_notification, name='send_notification'),
]