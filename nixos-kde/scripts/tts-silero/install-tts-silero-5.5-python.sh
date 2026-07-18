#!/usr/bin/env bash
set -e

echo "=== Установка Silero TTS V5.5 через Python ==="

INSTALL_DIR="$HOME/silero-tts-server"
VENV_DIR="$INSTALL_DIR/venv"

# Создаём директорию
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Создаём сервер
cat > server.py << 'PYEOF'
import os, io, wave, torch, numpy as np
from fastapi import FastAPI, Query
from fastapi.responses import Response
import uvicorn

app = FastAPI()

print("Загружаю модели...")
device = torch.device('cpu')
torch.set_num_threads(4)

# Русская V5.5
ru_file = os.path.expanduser('~/.cache/silero/v5_5_ru.pt')
if not os.path.isfile(ru_file):
    os.makedirs(os.path.dirname(ru_file), exist_ok=True)
    torch.hub.download_url_to_file('https://models.silero.ai/models/tts/ru/v5_5_ru.pt', ru_file)
ru_model = torch.package.PackageImporter(ru_file).load_pickle("tts_models", "model")
ru_model.to(device)

# Английская V3
en_file = os.path.expanduser('~/.cache/silero/v3_en.pt')
if not os.path.isfile(en_file):
    os.makedirs(os.path.dirname(en_file), exist_ok=True)
    torch.hub.download_url_to_file('https://models.silero.ai/models/tts/en/v3_en.pt', en_file)
en_model = torch.package.PackageImporter(en_file).load_pickle("tts_models", "model")
en_model.to(device)

print("Модели загружены!")

@app.get("/")
def root():
    return {"status": "Silero V5.5", "ru": True, "en": True}

@app.get("/speakers")
def speakers():
    return {"ru": ["aidar","baya","kseniya","xenia","eugene"], "en": ["en_0","en_1","en_2","en_3","en_4","en_5"]}

@app.get("/generate")
def generate(text: str = Query(...), speaker: str = Query("baya"), sample_rate: int = Query(48000)):
    model = en_model if speaker.startswith("en_") else ru_model
    audio = model.apply_tts(text=text, speaker=speaker, sample_rate=sample_rate)
    audio_int16 = (audio.numpy() * 32767).astype(np.int16)
    buffer = io.BytesIO()
    with wave.open(buffer, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio_int16.tobytes())
    buffer.seek(0)
    return Response(content=buffer.read(), media_type="audio/wav")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8002)
PYEOF

# Создаём venv
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install torch torchaudio fastapi uvicorn numpy

# Создаём systemd service
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/silero-tts.service << SVCEOF
[Unit]
Description=Silero TTS V5.5
After=network.target

[Service]
Type=simple
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/server.py
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
SVCEOF

systemctl --user daemon-reload
systemctl --user enable silero-tts
systemctl --user start silero-tts

echo "=== Готово! ==="
echo "URL: http://localhost:8002"
echo "Логи: journalctl --user -u silero-tts -f"
