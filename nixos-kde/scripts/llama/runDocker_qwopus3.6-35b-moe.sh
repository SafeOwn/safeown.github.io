#!/usr/bin/env bash

# Очищаем старые зависшие контейнеры
docker stop llama-server 2>/dev/null
docker rm llama-server 2>/dev/null
sleep 1

echo "🚀 Запуск Qwopus в интерактивном режиме с поддержкой нового CDI-рантайма..."
echo "🛑 Для остановки и выгрузки модели нажмите Ctrl+C или просто закройте этот терминал."
echo "--------------------------------------------------------------------------"
sleep 2

# ИЗМЕНЕНО: Удалены --runtime=nvidia и --gpus all
# ДОБАВЛЕН ФЛАГ: --device nvidia.com/gpu=all (Стандарт CDI)
docker run -it --rm --name llama-server \
  --device nvidia.com/gpu=all \
  --ipc=host \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
  -e GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 \
  -v /mnt/game:/mnt/game:ro \
  -p 8081:8081 \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  -m "/mnt/game/ai/ai-models-sd/LLM/Qwopus3.6-35B-A3B-v1-MTP-MXFP4_MOE-GGUF/Qwopus3.6-35B-A3B-v1-MTP-MXFP4_MOE.gguf" \
  --fit on \
  -ngl 99 \
  -ncmoe 27 \
  -c 160300 \
  -b 1024 \
  -ub 512 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --no-mmap \
  -t 12 \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0 \
  --presence-penalty 0 \
  --repeat-penalty 1.05 \
  --seed 42 \
  --jinja \
  --reasoning off \
  --reasoning-format none \
  --spec-type draft-mtp \
  --spec-draft-p-min 0.75 \
  --spec-draft-n-max 3 \
  --port 8081 \
  --host 0.0.0.0
