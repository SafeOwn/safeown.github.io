#!/usr/bin/env bash
# Универсальный скрипт сборки AppImage для AurexTranslator
# Работает на NixOS, Ubuntu, Fedora, Arch и других дистрибутивах

cat << 'DOCKER_SCRIPT' | docker run --rm -i -e DEBIAN_FRONTEND=noninteractive \
  -v ~/disk_kom/AurexTranslator:/src \
  -v ~/disk_kom/AurexTranslator/appimagetool-x86_64.AppImage:/tmp/appimagetool:ro \
  ubuntu:24.04 bash
set -euo pipefail

echo "📦 Установка зависимостей..."
apt-get update && apt-get install -y \
  cmake g++ qt6-base-dev libqt6svg6-dev qt6-tools-dev qt6-l10n-tools qt6-wayland \
  libopencv-dev libtesseract-dev libpipewire-0.3-dev libwayland-dev \
  libx11-dev libxcomposite-dev libxfixes-dev libxrandr-dev \
  libarchive-dev curl libgl1-mesa-dev file libfuse2 \
  libjpeg-turbo8-dev libpng-dev zlib1g-dev libfreetype6-dev \
  libwebp-dev libtiff-dev libicu-dev libdbus-1-dev libfontconfig1-dev libspatialite-dev

echo "🔧 Исправление #include..."
grep -qxF '#include <QDialogButtonBox>' /src/src/UI/textoutputwindow.cpp || sed -i '1i #include <QDialogButtonBox>' /src/src/UI/textoutputwindow.cpp
grep -qxF '#include <QJsonDocument>' /src/src/UI/mainwindow.cpp || sed -i '1i #include <QJsonDocument>' /src/src/UI/mainwindow.cpp

echo "🔨 Сборка проекта..."
cd /src
rm -rf build && mkdir build && cd build
cmake .. && make -j$(nproc)
cd ..

echo "📁 Подготовка AppDir..."
rm -rf AppDir
mkdir -p AppDir/usr/bin AppDir/usr/lib AppDir/usr/plugins

cp build/aurextranslator AppDir/usr/bin/
cp -r resources AppDir/ 2>/dev/null || true
cp -r /usr/lib/x86_64-linux-gnu/qt6/plugins/platforms AppDir/usr/plugins/
cp -r /usr/lib/x86_64-linux-gnu/qt6/plugins/imageformats AppDir/usr/plugins/ 2>/dev/null || true

# ❗ ВАЖНО: Мы НЕ исключаем libcurl, libssl, libcrypto. Они нужны для tesseract/gdal.
# Мы исключаем ТОЛЬКО glibc и компоненты звука, чтобы избежать крашей ABI.
copy_deps_safely() {
    ldd "$1" | grep "=> /" | awk '{print $3}' | \
    grep -v -E 'libc\.so|libpthread\.so|libdl\.so|libm\.so|librt\.so|libutil\.so|libresolv\.so|ld-linux|libnss|libpipewire|libspa|libpulse' | \
    xargs -I '{}' cp -v '{}' AppDir/usr/lib/ 2>/dev/null || true
}

copy_deps_safely build/aurextranslator
copy_deps_safely AppDir/usr/plugins/platforms/libqxcb.so
for plugin in AppDir/usr/plugins/imageformats/*.so; do copy_deps_safely "$plugin"; done

cp /usr/lib/x86_64-linux-gnu/libQt6*.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libopencv_*.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libtesseract.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/liblept.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libspatialite.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libgdal.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libgeos*.so* AppDir/usr/lib/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libproj.so* AppDir/usr/lib/ 2>/dev/null || true

# ❗ УНИВЕРСАЛЬНЫЕ ОБЁРТКИ: Работают и на NixOS, и на обычных дистрибутивах
# Они очищают LD_LIBRARY_PATH, чтобы системные утилиты не ломались от библиотек AppImage

cat > AppDir/usr/bin/curl << 'WRAPPER_EOF'
#!/bin/sh
if [ -x /run/current-system/sw/bin/curl ]; then
    exec env LD_LIBRARY_PATH="" /run/current-system/sw/bin/curl "$@"
else
    exec env LD_LIBRARY_PATH="" /usr/bin/curl "$@"
fi
WRAPPER_EOF
chmod +x AppDir/usr/bin/curl

cat > AppDir/usr/bin/paplay << 'WRAPPER_EOF'
#!/bin/sh
if [ -x /run/current-system/sw/bin/paplay ]; then
    exec env LD_LIBRARY_PATH="" /run/current-system/sw/bin/paplay "$@"
else
    exec env LD_LIBRARY_PATH="" /usr/bin/paplay "$@"
fi
WRAPPER_EOF
chmod +x AppDir/usr/bin/paplay

cat > AppDir/usr/bin/edge-tts << 'WRAPPER_EOF'
#!/bin/sh
if [ -x /run/current-system/sw/bin/edge-tts ]; then
    exec env LD_LIBRARY_PATH="" /run/current-system/sw/bin/edge-tts "$@"
else
    exec env LD_LIBRARY_PATH="" edge-tts "$@"
fi
WRAPPER_EOF
chmod +x AppDir/usr/bin/edge-tts

cat > AppDir/AppRun << 'APPRUN_EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export QT_PLUGIN_PATH="$HERE/usr/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="$HERE/usr/plugins/platforms"

# Программа использует библиотеки AppImage (включая libcurl/libssl для tesseract/gdal)
export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"

# Наши обёртки идут первыми в PATH, перехватывая вызовы и безопасно очищая окружение
export PATH="$HERE/usr/bin:/run/current-system/sw/bin:/usr/bin:/bin:$PATH"
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pulse/native"

exec "$HERE/usr/bin/aurextranslator" "$@"
APPRUN_EOF
chmod +x AppDir/AppRun

cat > AppDir/aurextranslator.desktop << 'DESKTOP_EOF'
[Desktop Entry]
Name=AurexTranslator
Exec=AppRun
Icon=application-vnd.appimage
Type=Application
Categories=Utility;
DESKTOP_EOF
touch AppDir/application-vnd.appimage.png

echo "🚀 Генерация AppImage..."
export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH=x86_64
/tmp/appimagetool AppDir /src/AurexTranslator-x86_64.AppImage

chown 1000:100 /src/AurexTranslator-x86_64.AppImage 2>/dev/null || true
echo "✅ УСПЕШНО! Универсальный AppImage создан."
DOCKER_SCRIPT
