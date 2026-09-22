#!/usr/bin/env bash
# Ручной запуск Silero TTS (альтернатива systemd-службе)
# Использует Python + torch из Nix, server.py из /etc/nixos/scripts/SileroTTS/

# ═════════════════════════════════════════════════════════════════════════
# TRAP — останавливает python при выходе / Ctrl+C / закрытии терминала
# ═════════════════════════════════════════════════════════════════════════
SERVER_PID=""
SERVICE_NAME="silero-tts.service"

cleanup_on_exit() {
    trap - EXIT INT TERM HUP
    echo ""
    echo "🛑 Останавливаю Silero TTS..."

    # Если запускали через этот скрипт — убьём python
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill -TERM "$SERVER_PID" 2>/dev/null || true
        sleep 1
        kill -9 "$SERVER_PID" 2>/dev/null || true
    fi

    # Если был запущен через systemd — тоже остановим
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true
    fi

    echo "✅ Silero TTS остановлен, порт освобождён"
}
trap cleanup_on_exit EXIT INT TERM HUP

# ═════════════════════════════════════════════════════════════════════════
# НАСТРОЙКИ
# ═════════════════════════════════════════════════════════════════════════
PORT=8002
SERVER_SCRIPT="/etc/nixos/scripts/SileroTTS/server.py"
SILERO_CMD="/run/current-system/sw/bin/silero-tts"
LOG_FILE="/tmp/silero-tts.log"

# ═════════════════════════════════════════════════════════════════════════
# ФУНКЦИИ
# ═════════════════════════════════════════════════════════════════════════
log()  { echo -e "\033[1;34m[$(date +%H:%M:%S)]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[✓]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }
err()  { echo -e "\033[1;31m[✗]\033[0m $*" >&2; }

check_files() {
    if [ ! -f "$SERVER_SCRIPT" ]; then
        err "Скрипт сервера не найден: $SERVER_SCRIPT"
        exit 1
    fi
    ok "server.py найден"

    if [ ! -x "$SILERO_CMD" ]; then
        err "Команда silero-tts не найдена: $SILERO_CMD"
        err "Проверь, что модуль /etc/nixos/modules/app/silero-tts.nix подключён"
        exit 1
    fi
    ok "Команда silero-tts найдена (Nix-пакет)"
}

# Останавливает systemd-службу, чтобы не было конфликта по порту
stop_systemd_service() {
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        warn "Останавливаю systemd-службу $SERVICE_NAME (чтобы не занимала порт)"
        sudo systemctl stop "$SERVICE_NAME"
        sleep 2
    fi
}

free_port() {
    local pid
    pid=$(ss -tulpn 2>/dev/null | grep ":$PORT " | grep -oP 'pid=\K[0-9]+' | head -1)
    if [ -z "$pid" ]; then
        ok "Порт $PORT свободен"
        return 0
    fi
    warn "Порт $PORT занят (PID $pid). Освобождаю..."
    sudo kill -9 "$pid" 2>/dev/null || true
    sleep 1
    ss -tulpn 2>/dev/null | grep -q ":$PORT " && { err "Не удалось освободить"; exit 1; }
    ok "Порт $PORT освобождён"
}

# ═════════════════════════════════════════════════════════════════════════
# ОСНОВНОЙ СЦЕНАРИЙ
# ═════════════════════════════════════════════════════════════════════════
clear
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  🔊 Silero TTS V5.5 + V3 (ручной запуск)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

check_files
stop_systemd_service
free_port

echo ""
echo "───────────────────────────────────────────────────────────────────"
echo "  Сервер: http://127.0.0.1:$PORT"
echo "  Лог:    $LOG_FILE"
echo "  Ctrl+C или закрытие окна — остановит сервер"
echo "───────────────────────────────────────────────────────────────────"
echo ""

# ═════════════════════════════════════════════════════════════════════════
# ЗАПУСК
# ═════════════════════════════════════════════════════════════════════════
# Запускаем в фоне, чтобы trap сработал при закрытии
"$SILERO_CMD" > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Ждём, пока сервер поднимется (или упадёт)
log "Жду запуска сервера (модели могут качаться 1-2 минуты)..."
for i in $(seq 1 60); do
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        err "Сервер упал. Последние 30 строк лога:"
        tail -30 "$LOG_FILE"
        exit 1
    fi
    if curl -s "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
        ok "Сервер отвечает на http://127.0.0.1:$PORT"
        break
    fi
    sleep 2
done

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  ✅ Silero TTS работает"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Проверка:"
echo "  curl http://127.0.0.1:$PORT/"
echo ""
echo "Генерация:"
echo "  curl -G 'http://127.0.0.1:$PORT/generate' \\"
echo "       --data-urlencode 'text=Привет' \\"
echo "       --data-urlencode 'speaker=xenia' \\"
echo "       -o /tmp/test.wav"
echo ""
echo "Логи в реальном времени: tail -f $LOG_FILE"
echo ""
echo "Нажми Ctrl+C для остановки (или закрой окно)."
echo ""

# Стримим логи в foreground — тут bash ждёт, trap сработает при закрытии
tail -f "$LOG_FILE"
