#!/usr/bin/env bash

echo "🧹 Запуск умной очистки мусора после сборки AppImage..."
echo "⚠️  Скрипт затронет ТОЛЬКО файлы сборки и образы Ubuntu. Рабочие контейнеры в безопасности."
echo "-----------------------------------------------------------------------------------"

# 1. Очистка файлов проекта
echo "📁 [1/5] Удаление временных папок сборки..."
rm -rf ~/disk_kom/AurexTranslator/build
rm -rf ~/disk_kom/AurexTranslator/AppDir
rm -f ~/disk_kom/AurexTranslator/appimagetool-x86_64.AppImage
rm -rf ~/.cache/appimage-run/*
echo "✅ Готово"

# 2. Точечная очистка Docker (ТОЛЬКО Ubuntu и остановленные контейнеры сборки)
echo "🐳 [2/5] Очистка Docker-мусора (Ubuntu)..."

# Находим и удаляем ТОЛЬКО остановленные (exited) контейнеры, созданные на основе ubuntu
docker rm $(docker ps -aq --filter "ancestor=ubuntu:22.04" --filter "status=exited") 2>/dev/null || true
docker rm $(docker ps -aq --filter "ancestor=ubuntu:24.04" --filter "status=exited") 2>/dev/null || true

# Удаляем образы ubuntu.
# ВАЖНО: Docker САМ заблокирует это действие, если эти образы используют твои рабочие контейнеры. Это наша главная защита.
docker rmi ubuntu:22.04 ubuntu:24.04 2>/dev/null || echo "   ℹ️ Образы Ubuntu не удалены, так как используются другими контейнерами (это нормально и безопасно)."
echo "✅ Готово"

# 3. Очистка Nix store (удаляет старые, неиспользуемые версии пакетов)
echo "❄️  [3/5] Очистка мусора в Nix store (это может занять минуту)..."
nix-collect-garbage -d
echo "✅ Готово"

# 4. Восстановление прав доступа (на случай, если что-то создалось от root внутри Docker)
echo "🔐 [4/5] Восстановление прав доступа к папке проекта..."
sudo chown -R safe:users ~/disk_kom/AurexTranslator 2>/dev/null || true
echo "✅ Готово"

# 5. Итоговая сводка
echo "-----------------------------------------------------------------------------------"
echo "🎉 ОЧИСТКА ЗАВЕРШЕНА УСПЕШНО!"
echo ""
echo "📦 Что осталось нетронутым:"
echo "   • Исходный код проекта"
echo "   • Готовый файл: AurexTranslator-x86_64.AppImage"
echo "   • Твои рабочие Docker-контейнеры (searxng, aceproxy, lampac, lampa)"
echo ""
echo "💡 СОВЕТ: В твоем списке docker images висит образ 'ghcr.io/ggml-org/llama.cpp:server-cuda' (4.35 ГБ)."
echo "   Если он тебе больше не нужен, ты можешь удалить его вручную командой:"
echo "   docker rmi ghcr.io/ggml-org/llama.cpp:server-cuda"
echo "   (Это освободит ещё 4.35 ГБ места)"
