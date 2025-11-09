#!/usr/bin/env sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Пути к папкам рядом со скриптом
SRC_CONFIG="$SCRIPT_DIR/.config"
SRC_LOCAL="$SCRIPT_DIR/.local"

# Проверяем наличие
if [ ! -d "$SRC_CONFIG" ]; then
  echo "❌ Папка .config не найдена рядом со скриптом"
  exit 1
fi

if [ ! -d "$SRC_LOCAL" ]; then
  echo "❌ Папка .local не найдена рядом со скриптом"
  exit 1
fi

# Копируем .config → ~/.config
echo "🔁 Копирую .config → ~/.config ..."
mkdir -p "$HOME/.config"
cp -rLf "$SRC_CONFIG"/. "$HOME/.config"/
chmod -R u+rw "$HOME/.config"

# Копируем .local → ~/.local
echo "🔁 Копирую .local → ~/.local ..."
mkdir -p "$HOME/.local"
cp -rLf "$SRC_LOCAL"/. "$HOME/.local"/
chmod -R u+rw "$HOME/.local"

echo "✅ Готово. Конфиги и локальные файлы применены."
