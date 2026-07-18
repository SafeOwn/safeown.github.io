#!/usr/bin/env bash

# Очищаем старые зависшие сессии контейнера
docker stop llama-server 2>/dev/null
docker rm llama-server 2>/dev/null
sleep 1

echo "🚀 Запуск Qwen 2.5 Coder 14B Instruct Uncensored..."
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
  -m "/mnt/game/ai/ai-models-sd/LLM/Qwen2.5-Coder-14B-Instruct-Uncensored-GGUF/Qwen2.5-Coder-14B-Instruct-Uncensored-GGUF-q5_k_m.gguf" \
  -ngl 99 \
  -c 160300 \
  -b 1024 \
  -ub 512 \
  -np 1 \
  -fa on \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --no-mmap \
  -t 12 \
  --temp 0.3 \
  --top-p 0.9 \
  --top-k 40 \
  --seed 42 \
  --jinja \
  --port 8081 \
  --host 0.0.0.0
