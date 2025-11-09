#!/usr/bin/env bash
set -e

APP_DIR="/home/safe/.local/share/docker/lampac"
DATA_DIR="$APP_DIR/data"

mkdir -p "$APP_DIR" "$DATA_DIR"

# --- Dockerfile ---
cat > "$APP_DIR/Dockerfile" <<'EOF'
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*
RUN curl -L -k -o publish.zip https://github.com/immisterio/Lampac/releases/latest/download/publish.zip
RUN unzip publish.zip
EXPOSE 9118
CMD ["dotnet", "Lampac.dll", "/data/init.conf"]
EOF

# --- init.conf (только если нет) ---
if [ ! -f "$DATA_DIR/init.conf" ]; then
  echo '{"listenport":9118}' > "$DATA_DIR/init.conf"
  echo "✅ Создан конфиг: $DATA_DIR/init.conf"
fi

# --- Сборка и запуск ---
echo "🏗️ Сборка образа..."
docker build -t lampac-nixos "$APP_DIR"

echo "🚀 Запуск контейнера..."
docker rm -f lampac 2>/dev/null || true
docker run -d \
  --name lampac \
  --restart unless-stopped \
  -p 9118:9118 \
  -v "$DATA_DIR":/data \
  lampac-nixos

# --- Информация ---
IP=$(hostname -I | awk '{print $1}' | head -n1)
echo "✅ Lampac запущен!"
echo "📁 Все данные: $DATA_DIR"
echo "   → Конфиг: $DATA_DIR/init.conf (НЕ удаляйте!)"
echo "   → Кеш:    $DATA_DIR/cache/ (можно удалять)"
echo "🔌 Плагин: http://$IP:9118/online.js"
echo "🔁 Для бэкапа: скопируйте всю папку $APP_DIR"
