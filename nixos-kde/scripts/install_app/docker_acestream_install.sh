#!/usr/bin/env bash
# install-acestream-docker.sh — Ace Stream + AceProxy (рабочая версия для NixOS)

set -e

USER_HOME="/home/${USER}"
ACE_DIR="${USER_HOME}/.local/share/docker/acestream"
CONFIG_DIR="${ACE_DIR}/config"
CACHE_DIR="${ACE_DIR}/data"
PORT_ACE=6878
PORT_PROXY=8000
IMAGE_ACE="magnetikonline/acestream-server:3.1.49_debian_8.11"  # официальный образ
IMAGE_PROXY="aceproxy-local"

echo "🚀 Начинаем установку Ace Stream Engine + AceProxy на NixOS..."

# --- 1. Создаём директории ---
mkdir -p "${CONFIG_DIR}" "${CACHE_DIR}"
echo "📁 Директории созданы: ${ACE_DIR}"

# --- 2. Скачиваем Ace Stream образ ОДИН РАЗ ---
echo "⬇️ Скачиваем Ace Stream Engine (один раз из интернета)..."
docker pull "${IMAGE_ACE}"

# --- 3. Создаём Dockerfile для AceProxy ---
cat > "${ACE_DIR}/Dockerfile.aceproxy" <<'EOF'
FROM python:3.9-slim
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone https://github.com/pepsik-kiev/HTTPAceProxy.git .
RUN pip install --no-cache-dir "gevent==21.12.0" "psutil==5.8.0"
RUN sed -i "s|acecmd = 'acestreamengine|acecmd = 'false # acestreamengine|" aceconfig.py
RUN sed -i "s|acespawn = True|acespawn = False|" aceconfig.py
EXPOSE 8000
CMD ["python3", "acehttp.py"]
EOF

# --- 4. Проверяем Docker ---
if ! systemctl is-active --quiet docker; then
  echo "Запускаем Docker..."
  sudo systemctl start docker
fi

# --- 5. Останавливаем старые контейнеры ---
for name in acestream-server aceproxy; do
  docker stop "${name}" 2>/dev/null || true
  docker rm "${name}" 2>/dev/null || true
done

# --- 6. Собираем AceProxy ---
echo "🏗 Собираем AceProxy (один раз)..."
docker build -t "${IMAGE_PROXY}" -f "${ACE_DIR}/Dockerfile.aceproxy" "${ACE_DIR}"

# --- 7. Запускаем Ace Stream Engine ---
echo "🐳 Запускаем Ace Stream Engine..."
docker run -d \
  --name acestream-server \
  --restart unless-stopped \
  -p "${PORT_ACE}:${PORT_ACE}" \
  -p 8621:8621 \
  -v "${CACHE_DIR}:/root/.ACEStream" \
  "${IMAGE_ACE}"

# --- 8. Запускаем AceProxy ---
echo "🐳 Запускаем AceProxy..."
docker run -d \
  --name aceproxy \
  --restart unless-stopped \
  --network host \
  "${IMAGE_PROXY}"

# --- 9. Вывод ---
IP=$(hostname -I | awk '{print $1}' | head -n1 2>/dev/null || echo "127.0.0.1")

echo
echo "✅ Установка завершена!"
echo "🔗 Ace Stream: http://${IP}:${PORT_ACE}/webui"
echo "🔗 AceProxy:   http://${IP}:${PORT_PROXY}/pid/ВАШ_ID/stream.mp4"
echo
echo "📁 Кэш Ace Stream: ${CACHE_DIR}"
echo "💡 Очистка кэша: rm -rf ${CACHE_DIR}/*"
echo "✅ После перезагрузки — всё работает без интернета!"
