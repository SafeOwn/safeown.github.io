#!/usr/bin/env bash

# Простой скрипт: собирает NixOS конфиг и открывает в Kate
# Работает и от root, и от пользователя

OUTPUT="/home/safe/.cache/nixos-config-for-ai.txt"

# Убедимся, что папка есть
mkdir -p "$HOME/.cache" 2>/dev/null || mkdir -p "/home/safe/.cache"

# Очистим старый файл
rm -f "$OUTPUT" 2>/dev/null

# Собираем структуру
echo "FILES AND STRUCTURE:" > "$OUTPUT"
find /etc/nixos -type f -name "*.nix" | sort >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Содержимое файлов
find /etc/nixos -type f -name "*.nix" | sort | while read file; do
  echo "=== $file ===" >> "$OUTPUT"
  cat "$file" >> "$OUTPUT"
  echo "" >> "$OUTPUT"
done

# Открываем
if [ "$(id -un)" = "root" ]; then
  # От root — переключаемся на safe
  sudo -u safe DISPLAY=$DISPLAY XDG_RUNTIME_DIR=/run/user/1000 \
    nohup kate "$OUTPUT" &> /dev/null &
else
  # От пользователя — просто запускаем
  nohup kate "$OUTPUT" &> /dev/null &
fi

echo "✅ Готово! Файл: $OUTPUT"
