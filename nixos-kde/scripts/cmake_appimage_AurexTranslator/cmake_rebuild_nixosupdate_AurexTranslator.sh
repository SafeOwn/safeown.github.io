#!/usr/bin/env bash
set -e
cd ~/disk_kom/AurexTranslator
echo "🧹 Очистка старой сборки..."
rm -rf build
mkdir build && cd build

echo "📦 Вход в окружение и сборка..."
nix-shell -p cmake pkg-config qt6.qtbase qt6.qtsvg qt6.qttools opencv tesseract pipewire wayland wayland-protocols libx11 libxcomposite libxfixes libxrandr libarchive curl libGL --run "
    echo '✅ Окружение готово. Запуск cmake...'
    cmake ..
    echo '🔨 Компиляция...'
    make -j\$(nproc)
    echo '🚀 Запуск приложения...'
    ./aurextranslator
"
