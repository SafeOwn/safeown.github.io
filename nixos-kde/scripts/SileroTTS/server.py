#!/usr/bin/env python3
"""Silero TTS V5.5 + V3 FastAPI сервер (CPU)"""
import os
import io
import wave
import logging

import numpy as np
import torch
from fastapi import FastAPI, Query, HTTPException
from fastapi.responses import Response
import uvicorn

logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] %(levelname)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("silero-tts")

app = FastAPI(title="Silero TTS")

# ── Настройки ───────────────────────────────────────────────────────────────
CACHE_DIR = os.path.expanduser("~/.cache/silero")
RU_URL = "https://models.silero.ai/models/tts/ru/v5_5_ru.pt"
EN_URL = "https://models.silero.ai/models/tts/en/v3_en.pt"
RU_FILE = os.path.join(CACHE_DIR, "v5_5_ru.pt")
EN_FILE = os.path.join(CACHE_DIR, "v3_en.pt")

device = torch.device("cpu")
torch.set_num_threads(4)

log.info("Torch version: %s", torch.__version__)
log.info("Device: %s, threads: 4", device)


def download_if_missing(url: str, path: str) -> None:
    """Скачать файл, если его нет. Идемпотентно."""
    if os.path.isfile(path) and os.path.getsize(path) > 1024:
        log.info("Модель уже есть: %s", path)
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    log.info("Скачиваю %s → %s", url, path)
    # Используем urllib вместо torch.hub — надёжнее и без сюрпризов
    import urllib.request
    tmp = path + ".part"
    try:
        urllib.request.urlretrieve(url, tmp)
        os.replace(tmp, path)
    except Exception:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise
    log.info("Готово: %s (%d байт)", path, os.path.getsize(path))


def load_model(path: str, name: str):
    log.info("Загружаю модель %s из %s", name, path)
    importer = torch.package.PackageImporter(path)
    model = importer.load_pickle("tts_models", "model")
    model.to(device)
    log.info("Модель %s загружена", name)
    return model


# ── Загрузка моделей при старте ─────────────────────────────────────────────
log.info("=== Инициализация Silero TTS ===")

download_if_missing(RU_URL, RU_FILE)
download_if_missing(EN_URL, EN_FILE)

ru_model = load_model(RU_FILE, "RU V5.5")
en_model = load_model(EN_FILE, "EN V3")

log.info("=== Сервер готов: http://127.0.0.1:8002 ===")


# ── API ─────────────────────────────────────────────────────────────────────
@app.get("/")
def root():
    return {"status": "Silero TTS", "ru": True, "en": True, "version": "v5.5+v3"}


@app.get("/speakers")
def speakers():
    return {
        "ru": ["aidar", "baya", "kseniya", "xenia", "eugene"],
        "en": ["en_0", "en_1", "en_2", "en_3", "en_4", "en_5"],
    }


@app.get("/generate")
def generate(
    text: str = Query(..., min_length=1, max_length=1000),
    speaker: str = Query("baya"),
    sample_rate: int = Query(48000, ge=8000, le=96000),
):
    try:
        model = en_model if speaker.startswith("en_") else ru_model
        audio = model.apply_tts(
            text=text, speaker=speaker, sample_rate=sample_rate
        )
    except Exception as e:
        log.exception("Ошибка генерации: %s", e)
        raise HTTPException(status_code=500, detail=str(e))

    audio_int16 = (audio.numpy() * 32767).astype(np.int16)
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio_int16.tobytes())
    buffer.seek(0)
    log.info("OK: speaker=%s, sample_rate=%d, text_len=%d", speaker, sample_rate, len(text))
    return Response(content=buffer.read(), media_type="audio/wav")


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8002, log_level="info")
