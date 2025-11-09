#!/usr/bin/env bash
# clear-media-cache.sh — полная очистка (работает даже с файлами от root)

set -e

USER_HOME="/home/${USER}"

LAMPAC_DATA="${USER_HOME}/.local/share/docker/lampac/data"
TORR_DATA="${USER_HOME}/.local/share/docker/torrserver/data"
ACE_DATA="${USER_HOME}/.local/share/docker/acestream/data"

clean_dir() {
  local dir="$1"
  local name="$2"

  if [ -d "$dir" ]; then
    echo "🧹 Очистка ${name}..."
    # sudo — потому что файлы созданы root'ом из контейнера
    sudo find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    echo "   → Удалено всё содержимое: ${dir}"
  else
    echo "⚠️  ${name}: папка не найдена (${dir})"
  fi
}

echo "🗑️  Начинаем полную очистку медиа-кеша..."

# Останавливаем контейнеры
echo "⏹️  Останавливаем контейнеры..."
for container in lampac torrserver acestream-server aceproxy; do
  if docker ps -q --filter "name=^/${container}$" 2>/dev/null | grep -q .; then
    echo "   Останавливаем ${container}..."
    docker stop "${container}" >/dev/null
  fi
done

# Очистка
clean_dir "$LAMPAC_DATA" "Lampac"
clean_dir "$TORR_DATA" "TorrServer"
clean_dir "$ACE_DATA" "Ace Stream"

# Запускаем обратно
echo "▶️  Запускаем контейнеры..."
for container in lampac torrserver acestream-server aceproxy; do
  if docker ps -a -q --filter "name=^/${container}$" 2>/dev/null | grep -q .; then
    echo "   Запускаем ${container}..."
    docker start "${container}" >/dev/null
  fi
done

echo
echo "✅ Очистка завершена!"
echo "💡 Все файлы удалены, включая созданные от root."
