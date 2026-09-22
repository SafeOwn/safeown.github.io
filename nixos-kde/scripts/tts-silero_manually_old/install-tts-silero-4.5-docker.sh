#!/usr/bin/env bash
echo "Установка Silero TTS через Docker..."

# Удаляем старый контейнер
docker rm -f silero-tts 2>/dev/null

# Запускаем (пробуем официальный образ)
docker run -d \
    --name silero-tts \
    --restart unless-stopped \
    -p 8002:8000 \
    ghcr.io/ouoertheo/silero-api-server:latest

echo "Готово! URL: http://localhost:8002"
echo "Проверка: curl http://localhost:8002/"
