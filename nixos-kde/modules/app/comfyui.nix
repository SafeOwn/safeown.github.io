{ pkgs, lib, config, ... }:

let
  # ── Фиксированная версия Python ─────────────────────────────────────────
  pythonForComfy = pkgs.python313;

  # ── Библиотеки для torch, opencv и нативных расширений ──────────────────
  extraLibs = with pkgs; [
    stdenv.cc.cc.lib   # libstdc++.so.6
    zlib
    zstd
    libGL
    libglvnd
    glib

    # X11 базовые
    libx11
    libxext
    libxrender
    libsm
    libice

    # XCB — базовый пакет (включает randr, render, shape, sync и др.)
    libxcb

    # XCB утилиты (актуальные имена верхнего уровня)
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm

    # Зависимости XCB
    libxau
    libxdmcp
    libxkbcommon
    libpthread-stubs
    xorgproto
  ];

  # ── Python-скрипт конвертации workflow ──────────────────────────────────
  convertWorkflows = pkgs.writeTextFile {
    name = "convert_workflows";
    executable = true;
    destination = "/bin/convert_workflows.py";
    text = builtins.readFile ../../scripts/ComfyUI/convert_workflows.py;
    checkPhase = ''
      ${pythonForComfy}/bin/python3 -m py_compile $out/bin/convert_workflows.py
    '';
  };

  # ── Основной скрипт запуска ComfyUI ─────────────────────────────────────
  comfyui = pkgs.writeShellApplication {
    name = "comfyui";
    runtimeInputs = with pkgs; [
      pythonForComfy
      curl
      brave
      xdg-utils
      coreutils
      util-linux     # для setsid
    ];
    text = ''
      set -euo pipefail

      COMFYUI_DIR="/mnt/game/ai/ComfyUI_windows_portable"
      VENV_DIR="$HOME/comfyui_env"
      PY="$VENV_DIR/bin/python"
      REQ_FILE="$COMFYUI_DIR/ComfyUI/requirements.txt"

      # ═══════════════════════════════════════════════════════════════════
      # ШАГ 1. Проверка пути
      # ═══════════════════════════════════════════════════════════════════
      echo "🔍 [1/6] Проверка пути ComfyUI..."
      [ ! -d "$COMFYUI_DIR/ComfyUI" ] && { echo "❌ ComfyUI не найден"; exit 1; }
      echo "   ✓ путь найден"

      # ═══════════════════════════════════════════════════════════════════
      # ШАГ 2. LD_LIBRARY_PATH — САМЫМ ПЕРВЫМ, до всех import-проверок
      # ═══════════════════════════════════════════════════════════════════
      export LD_LIBRARY_PATH="${lib.makeLibraryPath extraLibs}:''${LD_LIBRARY_PATH:-}"
      export TRITON_LIBCUDA_PATH="/run/opengl-driver/lib"

      # ── Хелпер: установить пакет, если его нет, но НЕ падать при ошибке ──
      try_pip_install() {
          local mod="$1"
          local pkg="$2"
          if ! "$PY" -c "import $mod" 2>/dev/null; then
              echo "📦 Устанавливаю $pkg..."
              if ! "$PY" -m pip install "$pkg"; then
                  echo "⚠️  $pkg не установился — пропускаю (не критично)"
              fi
          fi
      }

      # ═══════════════════════════════════════════════════════════════════
      # ШАГ 3. venv и pip
      # ═══════════════════════════════════════════════════════════════════
      echo "🔍 [2/6] Проверка venv..."
      if [ ! -x "$PY" ] || ! "$PY" -c "import sys" 2>/dev/null; then
          echo "🐍 venv сломан или отсутствует — пересоздаю в $VENV_DIR..."
          rm -rf "$VENV_DIR"
          ${pythonForComfy}/bin/python3 -m venv --without-pip "$VENV_DIR"
      fi
      echo "   ✓ venv на месте"

      if ! "$PY" -m pip --version >/dev/null 2>&1; then
          echo "🔧 Устанавливаю pip в venv..."
          curl -sS https://bootstrap.pypa.io/get-pip.py | "$PY"
      fi
      echo "   ✓ pip на месте"

      # ═══════════════════════════════════════════════════════════════════
      # ШАГ 4. PyTorch и базовые зависимости ComfyUI
      # ═══════════════════════════════════════════════════════════════════
      echo "🔍 [3/6] Проверка PyTorch (может занять до 60 секунд)..."
      if ! "$PY" -c "import torch" 2>/dev/null; then
          echo "📦 Устанавливаю PyTorch (CUDA 12.6)..."
          "$PY" -m pip install --upgrade pip -q
          "$PY" -m pip install torch torchvision torchaudio \
              --index-url https://download.pytorch.org/whl/cu126 -q
      fi
      echo "   ✓ torch: $("$PY" -c 'import torch; print(torch.__version__)')"

      echo "🔍 Проверка зависимостей ComfyUI..."
      if ! "$PY" -c "import sqlalchemy" 2>/dev/null; then
          echo "📦 Устанавливаю зависимости ComfyUI (requirements.txt)..."
          "$PY" -m pip install -r "$REQ_FILE" -q
      fi
      echo "   ✓ зависимости на месте"

      echo "🔍 Проверка opencv..."
      if ! "$PY" -c "import cv2" 2>/dev/null; then
          echo "📦 Устанавливаю opencv-python-headless..."
          "$PY" -m pip uninstall -y opencv-python opencv-contrib-python 2>/dev/null || true
          "$PY" -m pip install opencv-python-headless -q
      fi
      echo "   ✓ opencv: $("$PY" -c 'import cv2; print(cv2.__version__)')"

      # ═══════════════════════════════════════════════════════════════════
      # ШАГ 5. Базовые пакеты и пакеты для custom_nodes
      # ═══════════════════════════════════════════════════════════════════
      echo "🔍 [4/6] Проверка базовых пакетов..."
      try_pip_install onnxruntime       onnxruntime-gpu
      try_pip_install whisper           openai-whisper
      try_pip_install diffusers         diffusers
      try_pip_install pywt              PyWavelets
      try_pip_install soundfile         soundfile
      try_pip_install pynvml            nvidia-ml-py

      echo "🔍 [5/6] Проверка пакетов для custom_nodes..."
      try_pip_install skimage           scikit-image
      try_pip_install webcolors         webcolors
      try_pip_install piexif            piexif
      try_pip_install deepdiff          deepdiff
      try_pip_install blend_modes       blend_modes
      try_pip_install kornia            kornia
      try_pip_install rotary_embedding_torch rotary_embedding_torch
      try_pip_install omegaconf         omegaconf
      try_pip_install hydra             hydra-core
      try_pip_install iopath            iopath
      try_pip_install insightface       insightface
      try_pip_install segment_anything  segment-anything
      try_pip_install ultralytics       ultralytics
      try_pip_install platformdirs      platformdirs
      try_pip_install ffmpeg            ffmpeg-python
      try_pip_install imageio_ffmpeg    imageio-ffmpeg
      try_pip_install pyloudnorm        pyloudnorm
      try_pip_install pymunk            pymunk
      try_pip_install dynamicprompts    dynamicprompts
      try_pip_install ollama            ollama
      try_pip_install ruaccent          ruaccent
      try_pip_install llama_cpp         llama-cpp-python
      try_pip_install speechbrain       speechbrain
      try_pip_install noisereduce       noisereduce

      # ── Пакеты для comfyui-lora-manager ─────────────────────────────────
      # Без них падает aiohttp при старте и ComfyUI закрывается с трейсбеком
      try_pip_install natsort           natsort
      try_pip_install send2trash        Send2Trash
      try_pip_install aiofiles          aiofiles
      try_pip_install toml              toml

      # ⚠️  НЕ СТАВИМ:
      #   pedalboard       — SIGILL, CPU не поддерживает
      #   nunchaku         — нет совместимой сборки
      #   bitsandbytes     — часто падает, тяжело
      #   pytorch_lightning — тяжело, только для SUPIR
      #   transparent_background — тяжело, для inspyrenet

      # ═══════════════════════════════════════════════════════════════════
      # ШАГ 6. Конвертация workflow и запуск
      # ═══════════════════════════════════════════════════════════════════
      echo "🔍 [6/6] Конвертация workflow и запуск ComfyUI..."
      echo ""
      echo "✅ PyTorch: $("$PY" -c 'import torch; print(f"{torch.__version__}, CUDA={torch.cuda.is_available()}")')"
      echo "✅ OpenCV:  $("$PY" -c 'import cv2; print(cv2.__version__)')"
      echo ""

      export CUDA_VISIBLE_DEVICES=0
      cd "$COMFYUI_DIR/ComfyUI"
      "$PY" ${convertWorkflows}/bin/convert_workflows.py

      # ── Открыть браузер в ОТДЕЛЬНОЙ сессии ─────────────────────────────
      ( sleep 5 && setsid nohup env -u LD_LIBRARY_PATH brave \
          --password-store=basic \
          --disable-features=DbusSecretPortal \
          --enable-features=UseOzonePlatform \
          --ozone-platform=wayland \
          http://127.0.0.1:8188 \
          > /dev/null 2>&1 < /dev/null & ) || true

      echo ""
      echo "═══════════════════════════════════════════════════════════════"
      echo "  Запускаю ComfyUI на http://127.0.0.1:8188"
      echo "  Для остановки нажми Ctrl+C"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""

      exec "$PY" main.py --listen 127.0.0.1 --port 8188 \
          --extra-model-paths-config extra_model_paths_linux.yaml
    '';
  };

  # ── Иконка (PNG сконвертирован вручную) ─────────────────────────────────
  comfyuiIcon = pkgs.runCommand "comfyui-icon" { } ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${../../scripts/ComfyUI/comfyui.png} \
       $out/share/icons/hicolor/256x256/apps/comfyui.png
  '';

  # ── Ярлык для меню приложений ───────────────────────────────────────────
  comfyuiDesktop = pkgs.makeDesktopItem {
    name = "comfyui";
    exec = "comfyui";
    icon = "comfyui";
    desktopName = "ComfyUI";
    comment = "Stable Diffusion WebUI на базе ComfyUI";
    categories = [ "Graphics" "Development" "AudioVideo" ];
    startupWMClass = "comfyui";
    terminal = true;
  };
in
{
  # ── Установка в систему ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    pythonForComfy
    comfyui
    comfyuiIcon
    comfyuiDesktop
  ];

  # ── ЗАЩИТА от nix-collect-garbage -d ────────────────────────────────────
  system.activationScripts.comfyuiGcroot = lib.stringAfter [ "users" ] ''
    mkdir -p /nix/var/nix/gcroots/auto
    ln -sfn ${pythonForComfy} /nix/var/nix/gcroots/auto/comfyui-python313
    ${pkgs.nix}/bin/nix-store --add-root /nix/var/nix/gcroots/auto/comfyui-python313-closure \
        --indirect -r ${pythonForComfy} > /dev/null 2>&1 || true
  '';

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
}
