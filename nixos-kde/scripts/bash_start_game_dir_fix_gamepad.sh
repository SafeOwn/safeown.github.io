#!/usr/bin/env bash

echo "🔧 Исправляю shebang и делаю файлы исполняемыми..."
find /home/safe/game -name "*.sh" -type f \
  -exec chmod u+w {} \; \
  -exec sed -i '1s|.*|#!/usr/bin/env bash|' {} \; \
  -exec chmod +x {} \;

echo "🧹 Удаляю LD_PRELOAD из скриптов..."
find /home/safe/game -name "*.sh" -type f \
  -exec sed -i 's|]**||g' {} \;

echo "🚀 Добавляю steam-run, если его нет..."
find /home/safe/game -name "*.sh" -type f \
  -exec sed -i '/XMODIFIERS=.*\.[^ ]* *\$@/ { /steam-run/! s|\(XMODIFIERS *= *\)\(.*\)\(\./[^ ]* *\$@\)|\1\2steam-run \3| }' {} \;

echo " Исправляю библиотеки FMOD (execstack)..."
# Находим все libfmod*.so и исправляем их
find /home/safe/game -name "libfmod*.so" -type f | while read lib; do
    if execstack -q "$lib" 2>/dev/null | grep -q "X"; then
        echo "  Исправляю: $lib"
        execstack -c "$lib" 2>/dev/null
    fi
done

echo "🎮 Настраиваю геймпад для нативных игр..."
# Создаём универсальный wrapper для запуска игр с правильными настройками геймпада
cat > /home/safe/.local/bin/game-run-gamepad << 'WRAPPER'
#!/bin/bash
# Wrapper для запуска игр с поддержкой геймпада

export SDL_JOYSTICK_HIDAPI=0
export SDL_GAMECONTROLLERCONFIG=""
export SDL_JOYSTICK_DEVICE=/dev/input/js0

# Исправляем FMOD библиотеки в папке игры
GAME_DIR=$(dirname "$(readlink -f "$1")")
find "$GAME_DIR" -name "libfmod*.so" -type f 2>/dev/null | while read lib; do
    if execstack -q "$lib" 2>/dev/null | grep -q "X"; then
        execstack -c "$lib" 2>/dev/null
    fi
done

# Запускаем через steam-run
exec /home/safe/.local/bin/game-run "$@"
WRAPPER

chmod +x /home/safe/.local/bin/game-run-gamepad

echo "✨ Готово! Теперь можно запускать игры через game-run-gamepad"
echo ""
echo "Пример использования:"
echo "  game-run-gamepad /home/safe/game/Untitled\ Goose\ Game/Untitled.x86_64"
echo ""
echo "Или создай ярлык в Steam:"
echo "  Steam -> Добавить стороннюю игру -> выбери бинарник игры"
echo "  Затем в свойствах игры укажи параметры запуска: /home/safe/.local/bin/game-run-gamepad %command%"

# Автоматически создаём .desktop файлы для всех start.sh
while IFS= read -r -d '' start_script; do
    GAME_DIR=$(dirname "$start_script")
    GAME_NAME=$(basename "$GAME_DIR")
    DESKTOP_FILE=$HOME/.local/share/applications/${GAME_NAME}.desktop

    if [[ ! -f "$DESKTOP_FILE" ]]; then
        echo "🖥️ Создаю ярлык: $DESKTOP_FILE"
        cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$GAME_NAME
Exec=/home/safe/.local/bin/game-run-gamepad "$start_script"
Icon=$GAME_DIR/game/icon.png
Terminal=false
Type=Application
Categories=Game;
StartupWMClass=$GAME_NAME
EOF
    fi
done < <(find /home/safe/game -name "start.sh" -type f -print0)

# Обновляем базу приложений
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "✅ Все игры готовы к запуску с геймпадом!"

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
