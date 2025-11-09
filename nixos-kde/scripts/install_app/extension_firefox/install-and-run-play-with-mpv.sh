#!/usr/bin/env bash
set -e

# Конфигурация
USER="${SUDO_USER:-$USER}"
if [ "$USER" = "root" ]; then
  echo "❌ Запускайте от обычного пользователя, не от root."
  exit 1
fi

HOME_DIR="$HOME"
SRC_DIR="$HOME_DIR/.local/src/play-with-mpv"
VENV_DIR="$SRC_DIR/venv"
SERVICE_FILE="$HOME_DIR/.config/systemd/user/play-with-mpv.service"

# 1. Клонируем (если ещё не клонировано)
if [ ! -d "$SRC_DIR" ]; then
    mkdir -p "$HOME_DIR/.local/src"
    git clone https://github.com/alesar1/play-with-mpv.git "$SRC_DIR"
fi

cd "$SRC_DIR"

# 2. Убираем проблемную строку из setup.py
sed -i "s/['\"]install_freedesktop[^'\"]*['\"],\?//g" setup.py

# 3. Создаём виртуальное окружение (если не существует)
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

# 4. Устанавливаем зависимости
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install flask
"$VENV_DIR/bin/pip" install -e .

# 5. Создаём systemd user service
mkdir -p "$(dirname "$SERVICE_FILE")"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Play with MPV
After=graphical-session.target
PartOf=graphical-session.target

[Service]
ExecStartPre=/bin/sleep 3
ExecStart=%h/.local/src/play-with-mpv/venv/bin/play-with-mpv

[Install]
WantedBy=graphical-session.target
EOF

# 6. Включаем службу
systemctl --user daemon-reload
systemctl --user enable --now play-with-mpv.service

# 7. Разрешаем запуск без входа в сессию (опционально, но полезно)
if command -v loginctl >/dev/null; then
  sudo loginctl enable-linger "$USER"
fi

echo "✅ Установка и автозагрузка настроены!"
echo "Не забудьте установить расширение https://addons.mozilla.org/ru/firefox/addon/play-with-mpv/"
echo "Сервис запущен: http://localhost:7531"
echo "Управлять: systemctl --user {status,start,stop} play-with-mpv"
