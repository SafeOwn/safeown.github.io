#!/usr/bin/env bash
set -e

COMFYUI_DIR="/mnt/game/ai/ComfyUI_windows_portable"
VENV_DIR="$HOME/comfyui_env"
ICON_PATH="/mnt/game/ai/ComfyUI_windows_portable/ComfyUI/comfyui.ico"
DESKTOP_DIR=$(xdg-user-dir DESKTOP)

# libstdc++ для NixOS
export LD_LIBRARY_PATH="/nix/store/ysdkxvcvy2sy36sqigkyqanixm76z2xh-gcc-14.3.0-lib/lib:$LD_LIBRARY_PATH"

echo "🔍 Проверка путей..."
[ ! -d "$COMFYUI_DIR/ComfyUI" ] && { echo "❌ ComfyUI не найден"; exit 1; }

echo "🐍 Python окружение в $VENV_DIR..."
[ ! -d "$VENV_DIR" ] && python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "📦 Устанавливаю PyTorch с CUDA 12.1..."
pip install --upgrade pip -q
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 -q

echo "📦 Устанавливаю зависимости ComfyUI..."
pip install -r "$COMFYUI_DIR/ComfyUI/requirements.txt" -q

echo "📦 Устанавливаю доп. пакеты для custom_nodes..."
pip install opencv-python onnxruntime-gpu openai-whisper -q

echo "✅ PyTorch: $(python -c "import torch; print(f'{torch.__version__}, CUDA={torch.cuda.is_available()}')")"

deactivate

echo "🔧 Создаю скрипт конвертации workflow..."
cat > "$COMFYUI_DIR/ComfyUI/convert_workflows.py" << 'CONVERT_EOF'
#!/usr/bin/env python3
import json
from pathlib import Path

def fix_paths(obj):
    if isinstance(obj, str):
        return obj.replace('\\', '/')
    elif isinstance(obj, dict):
        return {k: fix_paths(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [fix_paths(item) for item in obj]
    return obj

def convert_all():
    workflows_dir = Path("user/default/workflows")
    linux_dir = Path("user/default/workflows/linux")

    if not workflows_dir.exists():
        return

    linux_dir.mkdir(parents=True, exist_ok=True)

    count = 0
    for json_file in workflows_dir.rglob("*.json"):
        try:
            json_file.relative_to(linux_dir)
            continue
        except ValueError:
            pass

        try:
            rel_path = json_file.relative_to(workflows_dir)

            with open(json_file, 'r', encoding='utf-8') as f:
                workflow = json.load(f)

            fixed = fix_paths(workflow)

            output_path = linux_dir / rel_path
            output_path.parent.mkdir(parents=True, exist_ok=True)

            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(fixed, f, indent=2, ensure_ascii=False)

            count += 1
        except Exception as e:
            print(f"[convert] Ошибка в {json_file}: {e}")

    if count > 0:
        print(f"[convert] Создано {count} Linux-workflow в {linux_dir}")

if __name__ == "__main__":
    convert_all()
CONVERT_EOF
chmod +x "$COMFYUI_DIR/ComfyUI/convert_workflows.py"

echo "🔧 Создаю скрипт запуска..."
cat > "$COMFYUI_DIR/run_nvidia_gpu_linux.sh" << 'EOF'
#!/usr/bin/env bash
cd /mnt/game/ai/ComfyUI_windows_portable

export LD_LIBRARY_PATH="/nix/store/ysdkxvcvy2sy36sqigkyqanixm76z2xh-gcc-14.3.0-lib/lib:$LD_LIBRARY_PATH"
export CUDA_VISIBLE_DEVICES=0

source ~/comfyui_env/bin/activate
cd ComfyUI

# Автоконвертация workflow
python3 convert_workflows.py

# Открываю Brave без KWallet и под Wayland через 5 секунд в фоне
(sleep 5 && brave --password-store=basic --disable-features=DbusSecretPortal --enable-features=UseOzonePlatform --ozone-platform=wayland http://127.0.0.1:8188 2>/dev/null) &


python main.py --listen 127.0.0.1 --port 8188 --extra-model-paths-config extra_model_paths_linux.yaml
EOF
chmod +x "$COMFYUI_DIR/run_nvidia_gpu_linux.sh"

echo "📁 Создаю Linux-конфиг путей моделей..."
cat > "$COMFYUI_DIR/ComfyUI/extra_model_paths_linux.yaml" << 'EOF'
forge:
     base_path: /mnt/game/ai/ai-models-sd
     checkpoints: Stable-diffusion
     configs: Stable-diffusion
     vae: VAE
     loras: |
          Lora
          LyCORIS
     upscale_models: |
                  ESRGAN
                  RealESRGAN
                  SwinIR
     embeddings: embeddings
     hypernetworks: hypernetworks
     controlnet: ControlNet
     text_encoders: text_encoder
     clip_vision: clip_vision
     diffusion_models: Stable-diffusion
     unet: Stable-diffusion
     llm: LLM
     prompt_generator: prompt_generator
     seedvr2: SEEDVR2
EOF

echo "🖥️ Создаю ярлыки (рабочий стол: $DESKTOP_DIR)..."
mkdir -p "$DESKTOP_DIR" ~/.local/share/applications

# Ярлык с Konsole (работает в KDE Plasma)
cat > "$DESKTOP_DIR/ComfyUI.desktop" << EOF
[Desktop Entry]
Name=ComfyUI
Comment=Запуск ComfyUI (Linux)
Exec=konsole --hold -e bash /mnt/game/ai/ComfyUI_windows_portable/run_nvidia_gpu_linux.sh
Type=Application
Categories=Graphics;
StartupNotify=true
Path=/mnt/game/ai/ComfyUI_windows_portable/
Icon=$ICON_PATH
Terminal=false
EOF

chmod +x "$DESKTOP_DIR/ComfyUI.desktop"
gio set "$DESKTOP_DIR/ComfyUI.desktop" metadata::trusted true

# В меню приложений
cp "$DESKTOP_DIR/ComfyUI.desktop" ~/.local/share/applications/
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo ""
echo "✅ Установка завершена!"
echo ""
echo "📂 Структура:"
echo "   $COMFYUI_DIR/ComfyUI/      — код (общий с Windows)"
echo "   /mnt/game/ai/ai-models-sd/ — модели (52 ГБ, общие)"
echo "   $VENV_DIR/                 — Python Linux (~3 ГБ)"
echo ""
echo "🚀 Запуск:"
echo "   • Ярлык ComfyUI на рабочем столе"
echo "   • bash $COMFYUI_DIR/run_nvidia_gpu_linux.sh"
echo ""
echo "🌐 Адрес: http://127.0.0.1:8188 (откроется автоматически)"
echo ""
echo "📁 Workflow:"
echo "   • Оригиналы (Windows): user/default/workflows/"
echo "   • Linux-копии: user/default/workflows/linux/"
