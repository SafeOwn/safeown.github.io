#!/usr/bin/env bash

# =============================================================
# 🧹 NixOS Full Cleanup Script (with Home Directory Support)
# ✅ Безопасно для NixOS — не трогает /nix/store вручную
# ✅ Чистит системные поколения, кэш, логи, дубли в /home
# ✅ Поддержка Steam/Proton, браузеров, thumbnails, etc.
# 💡 Запускать от обычного пользователя (некоторые команды с sudo)
# =============================================================

sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

echo "🚀 Начинаем полную очистку NixOS..."

# -------------------------------------------------------------
# 1. Очистка старых поколений NixOS (система)
# -------------------------------------------------------------
echo "🧹 Очищаем старые поколения системы (оставляем только текущее)..."
sudo nix-collect-garbage -d

# -------------------------------------------------------------
# 2. Оптимизация хранилища Nix (хардлинки одинаковых файлов)
# -------------------------------------------------------------
echo "🔗 Оптимизируем /nix/store через хардлинки..."
sudo nix-store --optimise

# -------------------------------------------------------------
# 3. Очистка логов systemd (journalctl)
# -------------------------------------------------------------
echo "🗑️  Очищаем системные логи старше 7 дней или больше 100M..."
sudo journalctl --vacuum-time=7d 2>/dev/null || true
sudo journalctl --vacuum-size=100M 2>/dev/null || true

# -------------------------------------------------------------
# 4. Очистка кэша nix (не /nix/store, а download cache)
# -------------------------------------------------------------
echo "📥 Очищаем кэш загрузок Nix (nix store cache)..."
nix-collect-garbage --delete-older-than 1d 2>/dev/null || true

# -------------------------------------------------------------
# 5. Очистка пользовательского кэша (~/.cache)
# -------------------------------------------------------------
echo "🧹 Очищаем кэш пользователя: браузеры, приложения, thumbnails..."

# Опасные папки — можно очищать полностью
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.cache/gnome-software/*
rm -rf ~/.cache/fontconfig/*
rm -rf ~/.cache/event-sound-cache*
rm -rf ~/.cache/docbook*

# Браузеры (если используешь — можно закомментировать ненужное)
rm -rf ~/.cache/mozilla/firefox/*/cache2/*
rm -rf ~/.cache/google-chrome/*/Cache/*
rm -rf ~/.cache/chromium/*/Cache/*
rm -rf ~/.cache/BraveSoftware/Brave-Browser/*/Cache/*

# Discord, Telegram, и др.
rm -rf ~/.cache/discord/*
rm -rf ~/.cache/TelegramDesktop/*

echo "✅ Кэш пользователя очищен."

# -------------------------------------------------------------
# 6. Очистка папки ~/.local/share/Trash (корзина)
# -------------------------------------------------------------
echo "🗑️  Очищаем корзину пользователя..."
sudo rm -rf ~/.local/share/Trash/*

# -------------------------------------------------------------
# 7. Очистка Steam/Proton кэша и дубликатов (опционально)
# -------------------------------------------------------------
# if [ -d "$HOME/.local/share/Steam" ] || [ -d "$HOME/.steam" ]; then
#     echo "🎮 Обнаружен Steam — чистим кэш и временные файлы..."
#
#     # Очистка общего кэша Steam
#     rm -rf ~/.local/share/Steam/steamapps/shadercache/*
#     rm -rf ~/.local/share/Steam/steamapps/temp/*
#
#     # Proton — можно оставить только последние версии
#     # (осторожно: если удалишь — переустановится при запуске игры)
#     echo "⚠️  ВНИМАНИЕ: Очистка Proton удалит все версии, кроме используемых!"
#     echo "   Если хочешь оставить — закомментируй следующие строки."
#
#     # Удалить ВСЕ версии Proton, кроме тех, что используются играми
#     # Сначала получим список используемых Proton версий из конфигов игр
#     if [ -d "$HOME/.local/share/Steam/steamapps/compatdata" ]; then
#         echo "🔍 Анализируем, какие версии Proton используются играми..."
#
#         # Создаем временный файл для хранения используемых версий
#         USED_PROTONS=$(mktemp)
#         find "$HOME/.local/share/Steam/steamapps/compatdata" -name "compatibilitytool.vdf" 2>/dev/null | while read vdf; do
#             grep -oP 'compat_tool_name"\s*"\K[^"]+' "$vdf" 2>/dev/null | while read tool; do
#                 echo "$tool" >> "$USED_PROTONS"
#             done
#         done
#
#         # Уникальные имена
#         sort -u "$USED_PROTONS" -o "$USED_PROTONS"
#
#         # Удаляем НЕиспользуемые версии Proton
#         PROTON_DIR="$HOME/.local/share/Steam/steamapps/common"
#         for proton in "$PROTON_DIR"/Proton*; do
#             if [ -d "$proton" ]; then
#                 proton_name=$(basename "$proton")
#                 if ! grep -q "^$proton_name$" "$USED_PROTONS"; then
#                     echo "❌ Удаляем неиспользуемый Proton: $proton_name"
#                     rm -rf "$proton"
#                 else
#                     echo "✅ Оставляем используемый Proton: $proton_name"
#                 fi
#             fi
#         done
#
#         rm -f "$USED_PROTONS"
#     fi
#
#     # Очистка shader cache (можно всегда — переформируется)
#     rm -rf ~/.local/share/Steam/steamapps/shadercache/*
# fi

# -------------------------------------------------------------
# 8. Поиск и удаление дубликатов в /home (опционально, требует fdupes)
# -------------------------------------------------------------
if command -v fdupes >/dev/null 2>&1; then
    echo "🔍 Ищем дубликаты в домашней директории (исключая .cache и .local/share/Steam)..."
    echo "⚠️  ВНИМАНИЕ: скрипт НЕ БУДЕТ удалять дубликаты автоматически — только покажет."
    echo "   Чтобы удалить — запусти вручную с флагом -d"

    fdupes -r -f -q \
        --exclude=".cache" \
        --exclude=".local/share/Steam" \
        --exclude=".thumbnails" \
        "$HOME" | grep -v "^$" || echo "Дубликаты не найдены."

    echo "💡 Совет: чтобы удалить дубликаты вручную: fdupes -rdN \$HOME"
else
    echo "📦 Установи fdupes для поиска дубликатов: nix-env -iA nixpkgs.fdupes"
fi

# -------------------------------------------------------------
# 9. Финальная статистика
# -------------------------------------------------------------
echo "📊 Статистика после очистки:"

echo "💾 Размер /nix/store:"
sudo du -sh /nix/store 2>/dev/null

echo "🏠 Размер домашней директории:"
du -sh "$HOME" 2>/dev/null

echo "📉 Размер кэша пользователя:"
du -sh "$HOME/.cache" 2>/dev/null

echo "🎉 Очистка завершена! Система легче и быстрее."
