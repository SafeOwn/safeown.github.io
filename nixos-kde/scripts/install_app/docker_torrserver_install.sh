#!/usr/bin/env bash
# install-torrserver-docker.sh — multi-arch ready (no local build)

set -e

TORR_USER="${USER}"
TORR_DIR="/home/${TORR_USER}/.local/share/docker/torrserver"
CONFIG_DIR="${TORR_DIR}/config"
DATA_DIR="${TORR_DIR}/data"
PORT=8090
CONTAINER_NAME="torrserver"
IMAGE="ghcr.io/yourok/torrserver:latest"  # multi-arch образ

mkdir -p "${CONFIG_DIR}" "${DATA_DIR}"

# Создаём accs.db
if [ ! -f "${CONFIG_DIR}/accs.db" ]; then
  echo '{"admin":"password123"}' > "${CONFIG_DIR}/accs.db"
  echo "✅ Создан accs.db"
fi

# Запускаем Docker
if ! systemctl is-active --quiet docker; then
  echo "Запускаем Docker..."
  sudo systemctl start docker
fi

# Пересоздаём контейнер
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker stop "${CONTAINER_NAME}" 2>/dev/null || true
  docker rm "${CONTAINER_NAME}" 2>/dev/null || true
fi

# Запускаем (без сборки!)
echo "Запускаем TorrServer из multi-arch образа..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${PORT}:${PORT}" \
  -v "${CONFIG_DIR}:/config" \
  -v "${DATA_DIR}:/data" \
  -e TS_PORT="${PORT}" \
  "${IMAGE}"

IP=$(hostname -I | awk '{print $1}' | head -n1 2>/dev/null || echo "127.0.0.1")

echo
echo "✅ TorrServer запущен!"
echo "   🔌 http://${IP}:${PORT}"
echo "   📁 Конфиг: ${CONFIG_DIR}/accs.db"
echo "   📁 Данные: ${DATA_DIR}/"
echo "   💡 Очистка: rm -rf ${DATA_DIR}/*"
