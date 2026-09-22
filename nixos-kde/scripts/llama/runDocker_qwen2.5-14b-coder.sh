#!/usr/bin/env bash
# Qwen 2.5 Coder 14B через llama.cpp
# Корректно останавливает контейнер при ЛЮБОМ способе закрытия

# ═════════════════════════════════════════════════════════════════════════
# TRAP — срабатывает при EXIT, Ctrl+C, kill, закрытии терминала
# ═════════════════════════════════════════════════════════════════════════
CONTAINER_NAME="llama-server"

cleanup_on_exit() {
    # Отключаем повторный вызов trap (иначе будет цикл)
    trap - EXIT INT TERM HUP

    echo ""
    echo "🛑 Останавливаю $CONTAINER_NAME..."

    # -t 3 — даём 3 секунды, потом SIGKILL
    docker stop -t 3 "$CONTAINER_NAME" >/dev/null 2>&1 || true
    # --rm должен был удалить сам, но на всякий случай
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

    echo "✅ Контейнер остановлен, порт освобождён"
}
trap cleanup_on_exit EXIT INT TERM HUP

# ═════════════════════════════════════════════════════════════════════════
# НАСТРОЙКИ
# ═════════════════════════════════════════════════════════════════════════
MODEL_PATH="/mnt/game/ai/ai-models-sd/LLM/Qwen2.5-Coder-14B-Instruct-Uncensored-GGUF/Qwen2.5-Coder-14B-Instruct-Uncensored-GGUF-q5_k_m.gguf"
PORT=8081
REGISTRY="ghcr.io/ggml-org/llama.cpp"

PREFERRED_TAGS=(
  "server-cuda12-b9879"
  "server-cuda-b9879"
  "server-cuda13-b9879"
  "server-cuda12-b9894"
  "server-cuda-b9894"
)

# ═════════════════════════════════════════════════════════════════════════
# ФУНКЦИИ
# ═════════════════════════════════════════════════════════════════════════

log()  { echo -e "\033[1;34m[$(date +%H:%M:%S)]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[✓]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }
err()  { echo -e "\033[1;31m[✗]\033[0m $*" >&2; }

check_docker() {
  systemctl is-active --quiet docker 2>/dev/null || { sudo systemctl start docker; sleep 2; }
  ok "Docker работает"
}

check_model() {
  [ -f "$MODEL_PATH" ] || { err "Модель не найдена: $MODEL_PATH"; exit 1; }
  ok "Модель найдена ($(du -h "$MODEL_PATH" | cut -f1))"
}

tag_exists()    { docker manifest inspect "$REGISTRY:$1" >/dev/null 2>&1; }
image_local()   { docker image inspect "$REGISTRY:$1"    >/dev/null 2>&1; }

find_tag() {
  log "Ищу доступный тег образа..."
  SELECTED_TAG=""
  for tag in "${PREFERRED_TAGS[@]}"; do
    printf "  %-30s " "$tag"
    if image_local "$tag"; then
      echo -e "\033[1;32m✅ скачан\033[0m"; SELECTED_TAG="$tag"; return 0
    elif tag_exists "$tag"; then
      echo -e "\033[1;33m⬇ доступен\033[0m"; SELECTED_TAG="$tag"; return 0
    else
      echo -e "\033[1;31m✗ нет\033[0m"
    fi
  done
  err "Ни один тег не найден"; exit 1
}

ensure_image() {
  if image_local "$SELECTED_TAG"; then
    ok "Образ уже локально"
    return 0
  fi
  log "Скачиваю $SELECTED_TAG (~4.3 ГБ)..."
  docker pull "$REGISTRY:$SELECTED_TAG" || { err "Ошибка скачивания"; exit 1; }
  ok "Образ скачан"
}

free_port() {
  local pid
  pid=$(ss -tulpn 2>/dev/null | grep ":$PORT " | grep -oP 'pid=\K[0-9]+' | head -1)
  if [ -z "$pid" ]; then
    ok "Порт $PORT свободен"
    return 0
  fi
  warn "Порт $PORT занят (PID $pid). Освобождаю..."
  docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  sleep 1
  pid=$(ss -tulpn 2>/dev/null | grep ":$PORT " | grep -oP 'pid=\K[0-9]+' | head -1)
  if [ -n "$pid" ]; then
    sudo kill -9 "$pid" 2>/dev/null || true
    sleep 1
  fi
  ss -tulpn 2>/dev/null | grep -q ":$PORT " && { err "Не удалось освободить"; exit 1; }
  ok "Порт $PORT освобождён"
}

# ═════════════════════════════════════════════════════════════════════════
# ОСНОВНОЙ СЦЕНАРИЙ
# ═════════════════════════════════════════════════════════════════════════

clear
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  🚀 Qwen 2.5 Coder 14B Instruct Uncensored (llama.cpp)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

check_docker
check_model
free_port
find_tag
echo ""
log "Выбран: $REGISTRY:$SELECTED_TAG"
ensure_image

# Убираем старый контейнер перед запуском
docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo ""
echo "───────────────────────────────────────────────────────────────────"
echo "  Сервер: http://127.0.0.1:$PORT"
echo "  Модель: $(basename "$MODEL_PATH")"
echo "  Ctrl+C или закрытие окна — остановит контейнер"
echo "───────────────────────────────────────────────────────────────────"
echo ""

# ═════════════════════════════════════════════════════════════════════════
# ЗАПУСК: сначала detached (-d), потом стрим логов (-f)
# ═════════════════════════════════════════════════════════════════════════
docker run -d \
  --name "$CONTAINER_NAME" \
  --rm \
  --device nvidia.com/gpu=all \
  --ipc=host \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
  -e GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 \
  -v /mnt/game:/mnt/game:ro \
  -p "127.0.0.1:$PORT:$PORT" \
  "$REGISTRY:$SELECTED_TAG" \
  -m "$MODEL_PATH" \
  -ngl 99 \
  -c 32768 \
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
  --port "$PORT" \
  --host 0.0.0.0

# Проверяем, что контейнер запустился
sleep 2
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  err "Контейнер не запустился. Логи:"
  docker logs "$CONTAINER_NAME" 2>&1 | tail -20
  exit 1
fi

# Стримим логи в foreground — тут bash ждёт, и trap сработает при закрытии
docker logs -f "$CONTAINER_NAME"

# Если дошли сюда — контейнер сам завершился. Trap сработает на EXIT.
