#!/bin/sh
set -e

echo "📦 Устанавливаю LuxWine..."

# Убедимся, что нужные пакеты установлены
if ! command -v appimage-run >/dev/null; then
  echo "❌ Требуется appimage-run. Установи через Nix."
  echo "Выполни: nix-env -iA nixos.appimage-run"
  exit 1
fi

# Создаём папку bin, если нет
mkdir -p ~/bin

# Скачиваем и делаем исполняемым
curl -L -o ~/bin/luxwine https://github.com/lwr/luxwine/releases/latest/download/luxwine.AppImage
chmod +x ~/bin/luxwine

# Запускаем — установит всё сам
~/bin/luxwine

echo "✅ LuxWine установлен. Значки должны появиться в меню."
echo "Обнови KDE: kquitapp5 plasmashell && kstart5 plasmashell"
