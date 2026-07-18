  # 🧠 Как переключить ядро:
  # 1. Раскомментируй нужное ядро ниже.
  # 2. Выполни: sudo nixos-rebuild boot --upgrade --flake /etc/nixos#pc --option description "🎮 XanMod"
  # 3. Перезагрузись → выбери ядро в меню.
  #
  # 📦 Занимает ~750 МБ на каждое ядро — программы не дублируются.
{ config, lib, pkgs, ... }:

let
  pkgs32 = import <nixpkgs> { system = "i686-linux"; };

  # ✅ Выбор ядра: раскомментируй нужное
  # ✅ Выбор ядра XanMod с исправлением ошибки загрузчика (bzImage) и фиксом BTF
  kernelPackages = pkgs.linuxPackages_xanmod.extend (self: super: {
    kernel = super.kernel.overrideAttrs (oldAttrs: {
      # 1. Отключаем проверку ошибок BTF, которая ломает сборку модулей
      ignore_btf_errors = true;

      # 2. Оставляем прошлый хак для загрузчика
      postInstall = (oldAttrs.postInstall or "") + ''
        if [ -f $out/vmlinuz ] && [ ! -f $out/bzImage ]; then
          ln -s vmlinuz $out/bzImage
        fi
      '';
    });
  });

  #kernelPackages = pkgs.linuxPackages_xanmod;             # 🎮 XanMod — для гейминга (⭐⭐⭐ FPS)
  # kernelPackages = pkgs.linuxPackages_latest;           # 🖥️ Стандартное последняя 6.16 — для стабильности (⭐ FPS)
  # kernelPackages = pkgs.linuxPackages;                  # 🖥️ Стандартное 6.6 — для стабильности (❌ FPS)
  # kernelPackages = pkgs.linuxPackages_zen;              # ⚖️ Баланс (⭐⭐ FPS)
  # kernelPackages = pkgs.cachyos.linuxPackages.cachyos;  # 🚀 CachyOS — максимум FPS на i9 (⭐⭐⭐⭐ FPS) нужно собирать вручную

  # ✅ Привязываем NVIDIA драйвер к выбранному ядру
  #nvidiaPackages = kernelPackages.nvidiaPackages.legacy_590;
  nvidiaPackages = kernelPackages.nvidiaPackages.beta;         # Самые свежие драйвера (595 или свежее)

  # --- РЕЖИМ: NVIDIA (по умолчанию) ---
  # Раскомментируй, чтобы использовать NVIDIA
  blacklistedKernelModules = [
    "i915"               # Intel GPU — ты используешь NVIDIA
    "int3515"            # Неизвестный модуль (возможно, от материнки)
    "spd5118"            # То же
    "acpi_cpufreq_init"  # Управление частотой CPU — может мешать performance governor
    "radeon"             # Старый AMD GPU драйвер — не нужен
  ];  #  Intel iGPU

  # --- РЕЖИМ: INTEL ---
  # Раскомментируй, чтобы использовать Intel (и закомментируй блок выше РЕЖИМ: NVIDIA) подключи HDMI к материнской плате
  # boot.blacklistedKernelModules = [   # сделай nixos-rebuild switch
  #   "nvidia"
  #   "nouveau"
  #   "nvidia-uvm"
  #   "nvidia-drm"
  #   "nvidia-modeset" "int3515" "spd5118"
  # ];
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
  # 📦 NVIDIA ДРАЙВЕР (open-source) ЯДРО
  # ==============================================================
  hardware.nvidia = {
    open = false;  # Отключаем open-драйвер
    package = nvidiaPackages; # или beta или latest # Включаем проприетарный
    nvidiaSettings = true;
    # Режимы
    modesetting.enable = true;
    powerManagement.enable = true;   # ✅ если false не будет сна
    powerManagement.finegrained = false;
  };

  boot.kernelPatches = [ ];
  boot.kernel.sysctl."fs.pipe-max-size" = 1048576;

  # Параметры ядра
  boot.kernelParams = lib.mkAfter [
    "mitigations=off"          # +FPS, -security (для игр нормально)  снижает безопасность, но даёт прирост FPS
    "nowatchdog"               # меньше задержек
    "threadirqs"               # IRQ в отдельных потоках → отзывчивость
    "drm.edid_firmware=DP-2:edid/dp-edid.bin"
    #"video=DP-2:3840x2160@160" # если расскоментировать проблема со сном, если разная герцовка тут 160 в kde 144, ошибка
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia-drm.modeset=1"
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
    options nvidia-drm modeset=1
    options nvidia NVreg_RegistryDwords="AllowFreesync=1; EnableFreesync=1; EnableGsync=1"
    options nvidia-drm modeset=1

    options nvidia_modeset vblank_sem_control=0
    options nvidia NVreg_TemporaryFilePath=/var/tmp
    options nvidia NVreg_InteractivePowerManagement=1
    options nvidia NVreg_EnableGpuFirmware=1
    options nvidia NvKmsForceCompositionPipeline=1
    install binder_linux /sbin/modprobe --all binder_linux devices="binder,hwbinder,vndbinder"
    install ashmem_linux /sbin/modprobe --all ashmem_linux
  '';

  services.xserver.displayManager.sessionCommands = ''
    # Принудительно включаем Full Range
    xrandr --output DP-2 --set "Broadcast RGB" "Full" > /dev/null 2>&1 &

    # Принудительно включаем HDR в NVIDIA
    nvidia-settings --assign "DigitalVibrance=1024" > /dev/null 2>&1 &
    nvidia-settings --assign "ColorRange=1" > /dev/null 2>&1 &
    nvidia-settings --assign "ColorSpace=1" > /dev/null 2>&1 &
    nvidia-settings --assign "ContentColorSpace=1" > /dev/null 2>&1 &

    # Включаем HDR-совместимые настройки
    nvidia-settings --assign "AllowHdmiHdcp=1" --assign "AllowHdcp=1" > /dev/null 2>&1 &

    # Запускаем твой скрипт
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
       DXVK_ASYNC = "1";  # ⚡ КРИТИЧНО для FPS в DXVK-играх
       DXVK_STATE_CACHE_PATH = "\${XDG_CACHE_HOME:-$HOME/.cache}/dxvk";
       VKD3D_SHADER_CACHE_PATH = "\${XDG_CACHE_HOME:-$HOME/.cache}/vkd3d";
       WINE_FULLSCREEN_FORCE_REFRESH = "1";
       VKD3D_CONFIG = "dxr11"; # улучшает HDR + DX12 производительность
       PROTON_ENABLE_FSYNC = "1"; # Proton GE — он включает Fsync автоматически, но лучше явно указать.
       PROTON_ENABLE_NVAPI = "1";
       __GL_SHADER_DISK_CACHE = "1";
       __GL_SHADER_DISK_CACHE_PATH = "\${XDG_CACHE_HOME:-$HOME/.cache}/nvidia";

#      MANGOHUD = "1";                     # Включает MangoHud по умолчанию
       WINEESYNC = "1";                    # Альтернатива Fsync (если Fsync не работает)
       WINEFSYNC = "1";                    # Явное включение Fsync
#        __GL_SYNC_TO_VBLANK = "0";          # Отключает vsync на уровне драйвера (если не нужен)
       SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0"; # Не минимизировать при потере фокуса
       GBM_BACKEND = "nvidia-drm";         # Для Wayland + NVIDIA
       SDL_VIDEODRIVER = "wayland";
       SDL_MOUSE_RELATIVE = "1";
       WINE_LARGE_ADDRESS_AWARE = "1";

       # ✅ Включение VRR в KWin (обязательно для NVIDIA + Wayland)
      KWIN_DRM_ALLOW_VRR = "1";
      KWIN_FORCE_REPAINT_ON_VSYNC = "1";
      KWIN_TRIPLE_BUFFER = "1";
      KWIN_USE_BUFFER_AGE = "1";
      KWIN_COMPOSE = "O2";

#       # Исправление для Tauri/WebKit приложений на NVIDIA (Clash Verge, Obsidian, etc)
#       WEBKIT_DISABLE_DMABUF_RENDERER = "0";
#       WEBKIT_DISABLE_COMPOSITING_MODE = "1";
#
#
#       # Принудительно только NVIDIA Vulkan (убирает Intel из Vulkan)
#       VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json";
#       __NV_PRIME_RENDER_OFFLOAD = "1";




#     __GL_THREADED_OPTIMIZATIONS = "1";  # NVIDIA: многопоточная оптимизация OpenGL    ВНИМВНИЕ!!! нет загрузки, ломает цвета в kde, fps
#     __EGL_VENDOR_LIBRARY_FILENAMES = "nvidia.json"; # Явное указание EGL              ВНИМВНИЕ!!! нет загрузки, ломает цвета в kde, fps


    LD_LIBRARY_PATH = "/run/opengl-driver/lib"; # если не отображается температура в виджетах
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Форсирует использование драйвера NVIDIA (не nouveau)
    __VK_LAYER_NV_optimus = "NVIDIA_only"; # Включает Vulkan на dGPU (важно для игр)

    # Для корректной работы Wayland с NVIDIA
    #WLR_NO_HARDWARE_CURSORS = "1";  # Убирает "дрожание" и шлейфы от аппаратного курсора
    #__GL_YIELD = "USLEEP";  # Уменьшает "агрессивность" драйвера NVIDIA, помогает от артефактов при переключении буферов

     # Для Offload Mode
#     __NV_PRIME_RENDER_OFFLOAD = "1";
#     __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";


    # Эти переменные управляют масштабом GUI-приложений.
    # Используй, если текст/иконки слишком мелкие на высоком разрешении (например, 4K).
    # Значение 1.0 = 100%, 1.2 = 120%, 2.0 = 200% и т.д.
#     GDK_SCALE = "2";          # 🟢 Масштаб GTK2/GTK3 приложений (например, Firefox, LibreOffice, GIMP)
#     GDK_DPI_SCALE = "1.2";      # 🟡 Дополнительное масштабирование DPI для GTK (обычно дублирует GDK_SCALE, но можно тонко настроить)
# #     QT_SCALE_FACTOR = "1.2";    # 🔵 Масштаб Qt5/Qt6 приложений (например, KDE, VLC, Telegram, qBittorrent)
#     SCALE_FACTOR = "1.2";           # 🟤 Универсальное масштабирование (поддерживается не всеми приложениями, например, Electron)
#     ELECTRON_SCALE_FACTOR = "1.2";  # 🟣 Для Electron-приложений (VSCode, Discord, Slack, Teams) — если не подхватывают сист масшт
    XCURSOR_SIZE = "28";            # 🖱️ Размер курсора мыши (по умолчанию 24, для HiDPI можно 32, 48, 64)



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
    libSM
    libXrender
    libX11                   # ✅ Основная X11 библиотека
    libXext                  # ✅ Расширения X11
    libXcursor               # ✅ Курсоры (важно для игр)
    libXi                    # ✅ Ввод (мышь, клавиатура)
    libXinerama              # ✅ Мультимонитор
    libXScrnSaver            # ✅ Защита экрана (иногда требуется)
    libXtst                  # ✅ Симуляция ввода (для автоматизации)
    libxshmfence             # ✅ Синхронизация GPU (важно для Vulkan)
    libXrandr                # ✅ Изменение разрешения
    libXxf86vm               # ✅ XFree86 видеомоды
    libXcomposite            # ✅ Compositing (для оконных менеджеров)
    libXdamage               # ✅ Отслеживание изменений в окнах
    libdrm                   # ✅ Прямой доступ к GPU
    libpciaccess             # ✅ Доступ к PCI-устройствам
    libva                    # ✅ Video Acceleration (VA-API)
    libvdpau                 # ✅ Video Decode and Presentation API (VDPAU)
    vulkan-tools           # → для vkcube
    kdePackages.kconfig    # → для kreadconfig5

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
    noto-fonts-color-emoji   # ✅ Эмодзи

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
    mesa-demos                  # ✅ Проверка OpenGL
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




    # ✅ Применяем ядро и чёрный список
  boot.kernelPackages = lib.mkDefault kernelPackages;
  boot.blacklistedKernelModules = lib.mkDefault blacklistedKernelModules;



  environment.etc."dconf/db/local.d/00-xwayland-vrr".text = ''
    [org/kde/kwin/xwayland]
    scale-monitor-framebuffer=true
    variable-refresh-rate=true
    native-scaling=true
  '';

  environment.etc."dconf/db/local.d/locks/xwayland-vrr".text = ''
    /org/kde/kwin/xwayland/scale-monitor-framebuffer
    /org/kde/kwin/xwayland/variable-refresh-rate
    /org/kde/kwin/xwayland/native-scaling
  '';

  system.activationScripts.updateDconf = let
    dconf = pkgs.dconf;
  in ''
    ${dconf}/bin/dconf update
  '';


  # === 🧩 ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ (не меняй) ===
  # ...
}
