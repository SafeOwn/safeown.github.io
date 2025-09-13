{
  config, lib,
  pkgs,
  ...
}:

let
  pkgs32 = import <nixpkgs> { system = "i686-linux"; };
in
{
  # ==============================================================
  # 🔐 Разрешить проприетарные и небезопасные пакеты
  # ==============================================================
  # Требуется для NVIDIA и qtwebengine
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"   # ✅ Разрешаем из-за ошибки при сборке
  ];

  # ==============================================================
  # 📦 NVIDIA ДРАЙВЕР (open-source)
  # ==============================================================
  hardware.nvidia = {
    open = false;  # Отключаем open-драйвер
    package = config.boot.kernelPackages.nvidiaPackages.beta; # или beta или latest # Включаем проприетарный
    nvidiaSettings = true;
    # Режимы
    modesetting.enable = true;
    powerManagement.enable = true;   # ✅ КРИТИЧНО
    powerManagement.finegrained = false;
  };

  # --- РЕЖИМ: NVIDIA (по умолчанию) ---
  # Раскомментируй, чтобы использовать NVIDIA
  boot.blacklistedKernelModules = [ "i915" "int3515" "spd5118" ];  #  Intel iGPU

  # --- РЕЖИМ: INTEL ---
  # Раскомментируй, чтобы использовать Intel (и закомментируй блок выше РЕЖИМ: NVIDIA) подключи HDMI к материнской плате
  # boot.blacklistedKernelModules = [   # сделай nixos-rebuild switch
  #   "nvidia"
  #   "nouveau"
  #   "nvidia-uvm"
  #   "nvidia-drm"
  #   "nvidia-modeset" "int3515" "spd5118"
  # ];

  # Параметры ядра
  boot.kernelParams = lib.mkAfter [
    "drm.edid_firmware=DP-2:edid/dp-edid.bin"
    #"video=DP-2:3840x2160@160" # если расскоментировать проблема со сном, если разная герцовка тут 160 в kde 144, ошибка
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    # Скрыть ядро вомманды при включении и выключении компьютера
    "quiet"
    "splash"
    "loglevel=3"        # Показывать только ошибки (не info/debug)
    "vt.global_cursor_default=0"  # Скрыть мигающий курсор
    "snd-intel-dspcfg.dsp_driver=1"  # Ускорение загрузки аудио-компонент
    "i915.fastboot=1" # (датчик освещённости клавиатуры) не может создать I2C-клиент
  ];

  # Кладём EDID в firmware
  hardware.firmware = [
    (pkgs.runCommand "dp-edid.bin" { } ''
      mkdir -p $out/lib/firmware/edid
      cp ${./dp-edid.bin} $out/lib/firmware/edid/dp-edid.bin
    '')
  ];

  # Дополнительные настройки модулей # Обязательный параметр: сохранять всю VRAM
  boot.extraModprobeConfig = ''
    options nvidia_modeset vblank_sem_control=0
    options nvidia NVreg_TemporaryFilePath=/var/tmp
    options nvidia NVreg_InteractivePowerManagement=1
    options nvidia NVreg_EnableGpuFirmware=1
    options nvidia NvKmsForceCompositionPipeline=1
    install binder_linux /sbin/modprobe --all binder_linux devices="binder,hwbinder,vndbinder"
    install ashmem_linux /sbin/modprobe --all ashmem_linux
  '';

  services.xserver.displayManager.sessionCommands = ''  # Атозагрузка для HDR цветов
    nvidia-settings --load-config-only &
    xrandr --output DP-2 --set "Broadcast RGB" "Full" &

    if [ "$XDG_SESSION_TYPE" = "x11" ] || [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      (/etc/nixos/scripts/nvidia-tray.py &) &
    fi
  '';

  # ========================================
  # 🔁 Prime Offload — Intel для рабочего стола, NVIDIA по запросу (или Prime Offload или specialisation)
  # ========================================
#     hardware.nvidia.prime = {
#       offload = {
#         enable = true;     # Использовать dNvidia и Intel iGPU вкл и выкл
#         enableOffloadCmd = true;  # Даёт команду `prime-run`
#       };
#         intelBusId = "PCI:0:2.0";   # ✅ Intel iGPU
#         nvidiaBusId = "PCI:1:0.0";  # ✅ NVIDIA RTX 4070 Ti
#     };


  # ========================================
  # 🖥️ OpenGL — включаем для игр и Wine
  # ========================================
  hardware.graphics.enable = true;

  # ==============================================================
  # 🖼️ МОНИТОР И EDID (DisplayPort)
  # ==============================================================

  # Переменные окружения для NVIDIA (важно для Wayland и Vulkan)
  environment.sessionVariables = {
    # Для NVIDIA
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Форсирует использование драйвера NVIDIA (не nouveau)
    __VK_LAYER_NV_optimus = "NVIDIA_only"; # Включает Vulkan на dGPU (важно для игр)

    # Для корректной работы Wayland с NVIDIA
    WLR_NO_HARDWARE_CURSORS = "1";  # Убирает "дрожание" и шлейфы от аппаратного курсора
    __GL_YIELD = "USLEEP";  # Уменьшает "агрессивность" драйвера NVIDIA, помогает от артефактов при переключении буферов

     # Для Offload Mode
#     __NV_PRIME_RENDER_OFFLOAD = "1";
#     __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";

    # Для масштабирования (если 4K) плохо масштабирует программы
    #GDK_SCALE = "2";
    #QT_SCALE_FACTOR = "2";

  };

  # ==============================================================
  # 🎮 ПОЛНЫЙ НАБОР ЗАВИСИМОСТЕЙ ДЛЯ ИГР НА LINUX (Wine, Proton, Steam, PortProton)
  # ==============================================================

  environment.systemPackages = with pkgs; [
    # === 🧱 БАЗОВЫЕ СИСТЕМНЫЕ ЗАВИСИМОСТИ ===
    # Эти пакеты нужны для работы FHS, bubblewrap, FUSE, и контейнеров
    fuse3                    # ✅ FUSE3 — для PortProton, Conty, Steam Flatpak
    pciutils                 # ✅ Для определения GPU (lspci)
    usbutils                 # ✅ Для определения контроллеров
    lm_sensors               # ✅ Мониторинг температуры
    upower                   # ✅ Управление питанием
    smartmontools            # ✅ Проверка SSD/HDD

    # === 🖥️ ГРАФИКА И ВИДЕО (Vulkan, OpenGL, X11, Wayland) ===
    # Критически важны для Wine, gamescope, DXVK, vkd3d
    vulkan-loader            # ✅ Vulkan loader (основа для DXVK/vkd3d)
    pkgsi686Linux.vulkan-loader  # ✅ 32-битный Vulkan loader
    libglvnd                 # ✅ Unified OpenGL/Vulkan dispatch
    pkgsi686Linux.libglvnd   # ✅ 32-битная версия
    mesa                     # ✅ OpenGL реализация
    pkgsi686Linux.mesa       # ✅ 32-битная версия
    egl-wayland              # ✅ Интеграция EGL с Wayland (для gamescope)
    xwayland                 # ✅ Запуск X11-приложений в Wayland
    xorg.libX11                   # ✅ Основная X11 библиотека
    xorg.libXext                  # ✅ Расширения X11
    xorg.libXcursor               # ✅ Курсоры (важно для игр)
    xorg.libXi                    # ✅ Ввод (мышь, клавиатура)
    xorg.libXinerama              # ✅ Мультимонитор
    xorg.libXScrnSaver            # ✅ Защита экрана (иногда требуется)
    xorg.libXtst                  # ✅ Симуляция ввода (для автоматизации)
    xorg.libxshmfence             # ✅ Синхронизация GPU (важно для Vulkan)
    xorg.libXrandr                # ✅ Изменение разрешения
    xorg.libXxf86vm               # ✅ XFree86 видеомоды
    xorg.libXcomposite            # ✅ Compositing (для оконных менеджеров)
    xorg.libXdamage               # ✅ Отслеживание изменений в окнах
    libdrm                   # ✅ Прямой доступ к GPU
    libpciaccess             # ✅ Доступ к PCI-устройствам
    libva                    # ✅ Video Acceleration (VA-API)
    libvdpau                 # ✅ Video Decode and Presentation API (VDPAU)

    # === 🎨 UI, ОКНА, ДЕКОРАЦИИ (для gamescope, PortProton, Wayland) ===
    libdecor                 # ✅ Современные рамки окон в Wayland
    gtk3                     # ✅ GTK3 — часто требуется для Wine-приложений
    glib-networking          # ✅ HTTPS в GTK
    dconf                    # ✅ Настройки GTK

    # === 🔊 АУДИО И СЕТЬ ===
    pulseaudio               # ✅ Аудио-сервер
    libpulseaudio            # ✅ Библиотека PulseAudio
    alsa-lib                 # ✅ ALSA (низкоуровневый аудио)
    gst_all_1."gst-plugins-base"    # ✅ Базовые плагины GStreamer
    gst_all_1."gst-plugins-good"    # ✅ Хорошие плагины (включая кодеки)
    gst_all_1."gst-plugins-bad"     # ✅ "Плохие", но рабочие плагины
    gst_all_1."gst-plugins-ugly"    # ✅ "Уродливые", но лицензированные (mp3, etc)

     # === 🔊 32-битные GStreamer (для Wine, EA, Origin, Ubisoft) ===
    (pkgsi686Linux.gst_all_1.gstreamer)   # ✅ Мультимедиа-фреймворк (для видео в EA/Origin)
    (pkgsi686Linux.gst_all_1."gst-plugins-base")
    (pkgsi686Linux.gst_all_1."gst-plugins-good")

    # === 🖋️ ШРИФТЫ И ЛОКАЛИ (для Wine, чтобы не было ошибок с font handles) ===
    freetype                 # ✅ Рендеринг шрифтов
    fontconfig               # ✅ Управление шрифтами
    (pkgsi686Linux.freetype) # ✅ 32-битная версия
    (pkgsi686Linux.fontconfig)
    corefonts                # ✅ Arial, Times New Roman и др. (обязательно для Wine)
    dejavu_fonts             # ✅ Широкая поддержка кириллицы (включая кириллицу)
    liberation_ttf           # ✅ Альтернатива corefonts
    noto-fonts               # ✅ Поддержка всех языков
    noto-fonts-cjk-sans      # ✅ Китайско-японско-корейские шрифты
    noto-fonts-emoji         # ✅ Эмодзи

    # === 🧰 ИНСТРУМЕНТЫ ДЛЯ ИГР ===
    gamemode                 # ✅ Режим производительности (Feral)
    mangohud                 # ✅ Оверлей с FPS, CPU, GPU
    vkbasalt                 # ✅ Пост-обработка (CAS, FSR, Tonemap)
    dxvk                     # ✅ DirectX 9-11 → Vulkan
    vkd3d                    # ✅ DirectX 12 → Vulkan
    #dxvk-nvapi               # ✅ Поддержка NVAPI в DXVK (для DLSS, Reflex)
    gamescope                # ✅ Изолированный X11-режим в Wayland
    wine
    winetricks               # ✅ Установка DLL и зависимостей в Wine
    #bottles
    lutris                   # ✅ Альтернативный лаунчер
    heroic                   # ✅ Лаунчер для Epic/GOG

    protonup-qt              # ✅ Рекомендуется — для установки свежих Proton GE
    protontricks
    cabextract               # ✅ нужен для установки .exe
    steam                    # ✅ Steam
    steam-unwrapped
    steam-run                # ✅ FHS-окружение для Steam

    # === 🛠️ ОТЛАДКА И ДИАГНОСТИКА ===
    glxinfo                  # ✅ Проверка OpenGL
    vulkan-tools             # ✅ Включает vulkaninfo, vkvia и др.
    mesa_glu                 # ✅ GLU библиотека
    yad                      # ✅ GUI-диалоги (для скриптов)
    imagemagick              # ✅ Обработка изображений
  ];

  # ========================================
  # 🎮 Gamescope — изолированный композитор
  # Нужен для FSYNC, VRR, улучшения input lag
  # ========================================
  programs.gamescope = {
    enable = true;
    capSysNice = true;  # ✅ Даёт gamescope право на высокий приоритет (FSYNC)
  };

  # ========================================
  # 🎮 Gamemode — повышает приоритет игр
  # ========================================
  programs.gamemode.enable = true;

  # ========================================
  # 🎮 Steam + Улучшения производительности
  # ========================================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;

    # === ЭТО ТО, ЧТО ТЕБЕ НАДО ДОБАВИТЬ ===
    extraCompatPackages = with pkgs; [ proton-ge-bin sc-controller ];
    # =====================================
  };

  # === 🧩 ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ (не меняй) ===
  # ...
}
