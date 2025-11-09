#!/usr/bin/env bash
set -e

APP_DIR="/home/safe/.local/share/docker/play-with-mpv"
DATA_DIR="$APP_DIR/data"
mkdir -p "$APP_DIR" "$DATA_DIR"

# --- Dockerfile ---
cat > "$APP_DIR/Dockerfile" <<'EOF'
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        mpv \
        yt-dlp \
        libasound2 \
        libx11-6 \
        libxkbcommon0 \
        libwayland-client0 \
        libwayland-cursor0 \
        libwayland-egl1 \
        libgl1 \
        libegl1 \
        libpulse0 \
    && rm -rf /var/lib/apt/lists/*

# Клонируем исходники
RUN git clone https://github.com/alesar1/play-with-mpv.git .

# Удаляем install_freedesktop из setup.py
RUN sed -i "s/['\"]install_freedesktop[^'\"]*['\"],\?//g" setup.py

# Устанавливаем
RUN pip install --no-cache-dir flask
RUN pip install --no-cache-dir .

EXPOSE 7531

CMD ["play-with-mpv"]
EOF

# --- Сборка ---
echo "🏗️ Сборка образа..."
docker build -t play-with-mpv-nixos "$APP_DIR"

# --- Остановка старого контейнера ---
docker rm -f play-with-mpv 2>/dev/null || true

# --- Запуск с правильным Wayland-пробросом ---
echo "🔄 Запуск контейнера..."

# Убедимся, что /run/user/1000 существует
sudo mkdir -p /run/user/1000
sudo chown 1000:1000 /run/user/1000

docker run -d \
  --name play-with-mpv \
  --restart unless-stopped \
  --network host \
  -v "$DATA_DIR":/root/.config/mpv \
  -v "$XDG_RUNTIME_DIR/pulse":/run/user/1000/pulse \
  -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY":/run/user/1000/$WAYLAND_DISPLAY \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
  --device /dev/dri \
  play-with-mpv-nixos

echo "✅ Готово!"
echo "   → Сервер: http://localhost:7531 (не открывай напрямую)"
echo "   → Проверка: curl 'http://localhost:7531/play?url=https://youtu.be/dQw4w9WgXcQ'"
echo "   → Или: ПКМ по видео в браузере → «Play with MPV»"
