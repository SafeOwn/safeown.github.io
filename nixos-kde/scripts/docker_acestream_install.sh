#!/usr/bin/env bash

set -e

echo "🚀 Начинаем установку Ace Stream Engine + AceProxy на NixOS..."

# --- 1. Создаём основные директории ---
ACESTREAM_DIR="$HOME/.local/share/acestream-docker"
ACEPROXY_DIR="$HOME/.local/share/aceproxy"
CACHE_DIR="$HOME/acestream-cache"  # <-- Кэш ВНЕ контейнера, легко чистить!

mkdir -p "$ACESTREAM_DIR" "$ACEPROXY_DIR" "$CACHE_DIR"

echo "📁 Директории созданы: $ACESTREAM_DIR, $ACEPROXY_DIR, $CACHE_DIR"

# --- 2. Клонируем репозиторий Ace Stream Docker ---
cd "$ACESTREAM_DIR"
if [ ! -d ".git" ]; then
    echo "⬇️  Клонируем magnetikonline/docker-acestream-server..."
    git clone https://github.com/magnetikonline/docker-acestream-server.git .
else
    echo "🔄 Репозиторий уже клонирован, обновляем..."
    git pull
fi

# --- 3. Исправляем shebang для NixOS ---
fix_shebang() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "🔧 Исправляем shebang в $file для NixOS..."
        sed -i 's|#!/bin/bash|#!/usr/bin/env bash\nset -e|' "$file"
        sed -i 's|#!/usr/bin/env bash -e|#!/usr/bin/env bash\nset -e|' "$file"
    fi
}

fix_shebang "run.sh"
fix_shebang "run-tmpfs.sh"

# Делаем скрипты исполняемыми
chmod +x run.sh run-tmpfs.sh playstream.py

echo "✅ Shebang исправлен, скрипты готовы."

# --- 4. Запускаем Ace Stream Engine с внешним кэшем ---
echo "🐳 Запускаем Ace Stream Engine с кэшем в $CACHE_DIR..."

# Останавливаем старый контейнер, если есть
docker stop acestream-server 2>/dev/null || true
docker rm acestream-server 2>/dev/null || true

# Запускаем с монтированием внешнего кэша
docker run -d \
    --name acestream-server \
    --restart unless-stopped \
    -p 6878:6878 \
    -p 8621:8621 \
    -v "$CACHE_DIR:/root/.ACEStream" \
    magnetikonline/acestream-server:3.1.49_debian_8.11

echo "✅ Ace Stream Engine запущен. Кэш хранится в: $CACHE_DIR"
echo "   Чтобы очистить кэш: rm -rf $CACHE_DIR/*"

# --- 5. Клонируем и настраиваем AceProxy ---
cd "$ACEPROXY_DIR"

if [ ! -d "HTTPAceProxy/.git" ]; then
    echo "⬇️  Клонируем AceProxy..."
    git clone https://github.com/pepsik-kiev/HTTPAceProxy.git
else
    echo "🔄 AceProxy уже клонирован, обновляем..."
    cd HTTPAceProxy && git pull && cd ..
fi

# --- 6. Создаём Dockerfile для AceProxy с фиксированными версиями ---
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/HTTPAceProxy
COPY ./HTTPAceProxy/ /opt/HTTPAceProxy/

# Совместимые версии для Python 3.9 и старого AceProxy
RUN pip install --no-cache-dir "gevent==21.12.0" "psutil==5.8.0"

# Отключаем встроенный движок — используем внешний на 127.0.0.1:6878
RUN sed -i "s|acecmd = 'acestreamengine|acecmd = 'false # acestreamengine|" /opt/HTTPAceProxy/aceconfig.py
RUN sed -i "s|acespawn = True|acespawn = False|" /opt/HTTPAceProxy/aceconfig.py

EXPOSE 8000
CMD ["python3", "acehttp.py"]
EOF

echo "✅ Dockerfile для AceProxy создан."

# --- 7. Собираем и запускаем AceProxy ---
echo "🐳 Собираем и запускаем AceProxy..."

docker stop aceproxy 2>/dev/null || true
docker rm aceproxy 2>/dev/null || true

docker build --no-cache -t aceproxy .
docker run -d \
    --network host \
    --name aceproxy \
    --restart unless-stopped \
    aceproxy

echo "✅ AceProxy запущен на порту 8000."

# --- 8. Проверка работы ---
echo ""
echo "🔍 Проверяем работу серверов..."

sleep 5

echo "→ Ace Stream Engine:"
curl -s "http://127.0.0.1:6878/webui/api/service?method=get_version" | jq . || echo "Установите 'jq' для красивого вывода, или игнорируйте."

echo "→ AceProxy:"
docker logs aceproxy | grep -E "(Server started|ERROR)" | tail -n 3

# --- 9. Инструкции по использованию ---
cat << EOF

🎉 УСТАНОВКА ЗАВЕРШЕНА!

📌 Основные команды:

1. Запуск потока через AceProxy (открывается в браузере/VLC):
   http://localhost:8000/pid/<ВАШ_ACE_STREAM_ID>/stream.mp4

2. Запуск потока напрямую через Ace Stream Engine (ТОЛЬКО в VLC/MPV):
   http://localhost:6878/ace/getstream?id=<ВАШ_ACE_STREAM_ID>&.mp4

3. Очистка кэша Ace Stream:
   rm -rf $CACHE_DIR/*

4. Остановка сервисов:
   docker stop acestream-server aceproxy

5. Запуск сервисов после перезагрузки:
   docker start acestream-server aceproxy

📌 Где что хранится:

- 📂 $ACESTREAM_DIR — скрипты run.sh, playstream.py, Dockerfile Ace Stream.
- 📂 $ACEPROXY_DIR — исходники AceProxy и его Dockerfile.
- 📂 $CACHE_DIR — кэш Ace Stream (видеофайлы, базы данных). Можно безопасно чистить.
- 🐳 Контейнеры: 'acestream-server', 'aceproxy' — управляются через docker.

📌 Совет: для просмотра в браузере используйте ссылки через AceProxy (порт 8000).
         Для максимальной стабильности — VLC с прямой ссылкой (порт 6878).

EOF

echo "✅ Готово! Приятного просмотра!"
