#!/usr/bin/env bash
set -e

echo "📥 Скачиваем open-in-mpv (Baldomo)..."
tmpdir=$(mktemp -d)
cd "$tmpdir"

wget -O linux.tar https://github.com/Baldomo/open-in-mpv/releases/download/v2.4.3/linux.tar
tar -xf linux.tar

echo "📦 Устанавливаем бинарник в ~/.local/bin..."
mkdir -p ~/.local/bin
cp open-in-mpv ~/.local/bin/
chmod +x ~/.local/bin/open-in-mpv

echo "🦊 Настраиваем Native Messaging для Firefox..."
mkdir -p ~/.mozilla/native-messaging-hosts

cat > ~/.mozilla/native-messaging-hosts/open_in_mpv.json <<EOF
{
  "name": "open_in_mpv",
  "description": "Play videos in mpv",
  "path": "$HOME/.local/bin/open-in-mpv",
  "type": "stdio",
  "allowed_extensions": [
    "{7a7a4867-f11b-4a15-9f3c-889b4e705d04}"
  ]
}
EOF

echo "✅ Установка завершена!"

echo
echo "❗ ВАЖНО:"
echo "1. Убедитесь, что ~/.local/bin есть в вашем PATH."
echo "   Выполните: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.profile"
echo "   Затем: source ~/.profile"
echo
echo "2. Установите зависимости:"
echo "   nix-shell -p mpv yt-dlp"
echo
echo "3. Установите расширение Firefox:"
echo "   https://github.com/Baldomo/open-in-mpv/releases/download/v2.4.3/firefox.xpi"
echo
echo "4. Перезапустите Firefox."
