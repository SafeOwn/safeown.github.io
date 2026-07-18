#!/usr/bin/env bash
echo "🔊 Тестирование EdgeTTS..."
OUTPUT_FILE="/tmp/edgetts_test.mp3"

# Генерация
echo "Генерация аудио..."
edge-tts --text "Привет! Это проверка работы Edge TTS в системе." --voice ru-RU-SvetlanaNeural --write-media "$OUTPUT_FILE"

# Проверка размера
SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "0")
if [ "$SIZE" -gt 10000 ]; then
    echo "✅ Успех! Файл создан, размер: $(ls -lh "$OUTPUT_FILE" | awk '{print $5}')"
    echo "▶️ Воспроизведение..."
    paplay "$OUTPUT_FILE"
    echo "🎵 Воспроизведение завершено."
else
    echo "❌ Ошибка! Файл слишком маленький или не создан. Размер: $SIZE байт."
    cat "$OUTPUT_FILE" # Покажет текст ошибки, если она есть
fi

rm -f "$OUTPUT_FILE"
