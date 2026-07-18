#!/usr/bin/env bash

# Очищаем старые зависшие сессии контейнера
docker stop llama-server 2>/dev/null
docker rm llama-server 2>/dev/null
sleep 1

echo "🚀 Запуск Qwen 3.6 Uncensored (с поддержкой Vision mmproj)..."
echo "🛑 Для остановки и выгрузки модели нажмите Ctrl+C или закройте этот терминал."
echo "--------------------------------------------------------------------------"
sleep 2

docker run -it --rm --name llama-server \
  --device nvidia.com/gpu=all \
  --ipc=host \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
  -e GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 \
  -v /mnt/game:/mnt/game:ro \
  -p 8081:8081 \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  -m "/mnt/game/ai/ai-models-sd/LLM/Qwen3.6-35B-A3B-Uncensored-Genesis-V2-APEX-MTP-GGUF/Qwen3.6-35B-A3B-Uncensored-Genesis-APEX-Compact.gguf" \
  --mmproj "/mnt/game/ai/ai-models-sd/LLM/Qwen3.6-35B-A3B-Uncensored-Genesis-V2-APEX-MTP-GGUF/mmproj-Qwen3.6-35B-A3B-Uncensored-Genesis-f16.gguf" \
  --fit on \
  -ngl 99 \
  -ncmoe 16 \
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
  --port 8081 \
  --host 0.0.0.0
