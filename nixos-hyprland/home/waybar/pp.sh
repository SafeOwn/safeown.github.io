#!/bin/bash

LOG_FILE="/tmp/asus-power-profile.log"
echo "Script started at $(date)" >> "$LOG_FILE"

# Получение текущего профиля
CURRENT_PROFILE=$(asusctl profile -p | grep Active | awk '{print $NF}')
echo "Current profile: $CURRENT_PROFILE" >> "$LOG_FILE"

# Определение иконки и текста подсказки
case "$CURRENT_PROFILE" in
  "Quiet")
    ICON="󰾆"
    TEXT="Quiet"
    ;;
  "Balanced")
    ICON="󰾅"
    TEXT="Balanced"
    ;;
  "Performance")
    ICON="󰓅"
    TEXT="Performance"
    ;;
  *)
    ICON="󰂭"
    TEXT="Unknown"
    ;;
esac

# Вывод JSON-объекта
OUTPUT="{\"text\": \"$ICON\", \"tooltip\": \"$TEXT\"}"
echo "$OUTPUT" >> "$LOG_FILE"
echo "$OUTPUT"

echo "Script finished at $(date)" >> "$LOG_FILE"

