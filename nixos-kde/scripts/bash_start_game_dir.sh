#!/usr/bin/env bash

echo "🔧 Исправляю shebang и делаю файлы исполняемыми..."
find /home/safe/game -name "*.sh" -type f \
  -exec chmod u+w {} \; \
  -exec sed -i '1s|.*|#!/usr/bin/env bash|' {} \; \
  -exec chmod +x {} \;

echo "🧹 Удаляю LD_PRELOAD из скриптов..."
find /home/safe/game -name "*.sh" -type f \
  -exec sed -i 's|]*" *||g' {} \;

echo "🚀 Добавляю steam-run, если его нет..."
find /home/safe/game -name "*.sh" -type f \
  -exec sed -i '/XMODIFIERS=.*\.[^ ]* *"\$@"/ { /steam-run/! s|\(XMODIFIERS *= *\)\(.*\)\(\./[^ ]* *"\$@"\)|\1\2steam-run \3| }' {} \;

echo "✨ Готово! Все игры должны запускаться."

# # Автоматически создаём .desktop файлы для всех start.sh
# while IFS= read -r -d '' start_script; do
#     GAME_DIR=$(dirname $start_script)
#     GAME_NAME=$(basename $GAME_DIR)
#     DESKTOP_FILE=$HOME/.local/share/applications/${GAME_NAME}.desktop
#
#     if [[ ! -f $DESKTOP_FILE]]; then
#         echo 🖥️ Создаю ярлык: $DESKTOP_FILE
#         cat > $DESKTOP_FILE<<EOF
# [Desktop Entry]
# Name=$GAME_NAME
# Exec=$start_script
# Icon=$GAME_DIR/game/icon.png
# Terminal=false
# Type=Application
# Categories=Game;
# StartupWMClass=$GAME_NAME
# EOF
#     fi
# done < <(find /home/safe/game -name start.sh-type f -print0)
#
# # Обновляем базу приложений
# update-desktop-database ~/.local/share/applications 2>/dev/null || true
#
# echo ✅ Все игры готовы к запуску!
