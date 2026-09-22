#!/usr/bin/env bash
echo "🔊 Тестирование твоего Silero TTS (FastAPI)..."
OUTPUT_FILE="/tmp/silero_native_test.wav"

echo "Отправка запроса с правильным URL-encoding..."
curl -s -G "http://localhost:8002/generate" \
     --data-urlencode "text=Привет! Теперь мы используем правильные параметры для твоего FastAPI сервера." \
     --data-urlencode "speaker=xenia" \
     --data-urlencode "sample_rate=48000" \
     -o "$OUTPUT_FILE"

SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "0")

if [ "$SIZE" -gt 5000 ]; then
    echo "✅ Успех! Файл создан, размер: $(ls -lh "$OUTPUT_FILE" | awk '{print $5}')"
    echo "▶️ Воспроизведение..."
    paplay "$OUTPUT_FILE"
    echo "🎵 Готово!"
else
    echo "❌ Ошибка! Размер файла: $SIZE байт."
    echo "Ответ сервера:"
    cat "$OUTPUT_FILE"
fi

rm -f "$OUTPUT_FILE"
