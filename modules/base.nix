# /etc/nixos/configuration.nix
# Основной конфиг NixOS: NVIDIA, Plasma, пользователи, сеть, EDID, CPU
{ config, pkgs, lib, ... }:

{
  #imports = [ ./hardware-configuration.nix ]; # нужен если без flake


  # Включаем flakes и nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
















  # ==============================================================
  # 🔐 СИСТЕМНЫЕ НАСТРОЙКИ
  # ==============================================================

  # Разрешить проприетарное ПО (NVIDIA)
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  # Имя машины
  networking.hostName = "nixos";

  # Сеть: включить NetworkManager
  networking.networkmanager.enable = true;

  # Часовой пояс
  time.timeZone = "Europe/Moscow";


  # ==============================================================
  # 🌍 ЛОКАЛИЗАЦИЯ И ЯЗЫК
  # ==============================================================

  # Поддерживаемые локали
  i18n.supportedLocales = [
    "ru_RU.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  # Язык по умолчанию
  i18n.defaultLocale = "ru_RU.UTF-8";

  # Раскладка в консоли (всегда US)
  console.font = "ter-v16n";  # Terminus 16px, с поддержкой кириллицы (Суффикс n = с кириллицей) ter-v20n  (размер 12-14-16-20)
  console.keyMap = lib.mkForce "us";
  console.useXkbConfig = true;



  # ==============================================================
  # 🖥️ ЗАГРУЗЧИК (UEFI)
  # ==============================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Количество отображения всего nixos rebuild сборок в boot
  boot.loader.timeout = 5;  # Выбор начального времини ОС и nixos rebuild

  boot.plymouth.enable = true; # Включить Plymouth (графический экран загрузки)
  boot.plymouth.theme = "spinner";  # Можно выбрать тему для Plymouth или другая

  # Основной раздел Win10 NTFS
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/CAB2E03CB2E02E9F";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "ro"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел Game NTFS там же где Linux
  fileSystems."/mnt/game" = {
    device = "/dev/disk/by-uuid/01DC10CC866597D0";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел SDD NTFS
  fileSystems."/mnt/sdd" = {
    device = "/dev/disk/by-uuid/766666326665F2F3";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел Archive NTFS
  fileSystems."/mnt/archive" = {
    device = "/dev/disk/by-uuid/635E73EE8E38A8CF";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел Program NTFS
  fileSystems."/mnt/program" = {
    device = "/dev/disk/by-uuid/49090D06A3D0E968";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел Disel NTFS
  fileSystems."/mnt/disel" = {
    device = "/dev/disk/by-uuid/E281603962F2F129";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };


  # ==============================================================
  # 🖥️ СИМВОЛИЧЕСКИЕ ССЫЛКИ РАЗДЕЛОВ
  # ==============================================================

  system.activationScripts.create-symlinks.text = ''
    USER_HOME="/home/safe"
    MNT="/mnt"

    # Проверяем, существует ли пользователь
    if [ ! -d "$USER_HOME" ]; then
      echo "Пользовательская папка $USER_HOME не существует"
      exit 1
    fi

    # Функция: безопасно создать символическую ссылку
    safe_link() {
      local target="$1"
      local link_name="$2"

      # Если это старая символическая ссылка — удаляем
      if [ -L "$link_name" ]; then
        rm -f "$link_name"
      fi

      # Если это директория (не ссылка) — не трогаем, но предупреждаем
      if [ -d "$link_name" ] && [ ! -L "$link_name" ]; then
        echo "Внимание: $link_name — это директория, а не ссылка. Пропускаем."
        return
      fi

      # Создаём новую ссылку
      ln -sf "$target" "$link_name"
    }

    # Создаём ссылки
    safe_link "$MNT/windows"    "$USER_HOME/Windows"
    safe_link "$MNT/game"       "$USER_HOME/Games"
    safe_link "$MNT/program"    "$USER_HOME/Programs"
    safe_link "$MNT/archive"    "$USER_HOME/Archive"
    safe_link "$MNT/sdd"        "$USER_HOME/SDD"
    safe_link "$MNT/disel"      "$USER_HOME/Disel"

    echo "Символические ссылки проверены и созданы."
  '';

  # ==============================================================
  # 📦 NVIDIA ДРАЙВЕР (open-source)
  # ==============================================================

  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # --- РЕЖИМ: NVIDIA (по умолчанию) ---
  # Раскомментируй, чтобы использовать NVIDIA
  boot.blacklistedKernelModules = [ "i915" ];

  # --- РЕЖИМ: INTEL ---
  # Раскомментируй, чтобы использовать Intel (и закомментируй блок выше РЕЖИМ: NVIDIA) подключи HDMI к материнской плате
  # boot.blacklistedKernelModules = [   # сделай nixos-rebuild switch
  #   "nvidia"
  #   "nouveau"
  #   "nvidia-uvm"
  #   "nvidia-drm"
  #   "nvidia-modeset"
  # ];

  # Параметры ядра
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"

    # Скрыть ядро вомманды при включении и выключении компьютера
    "quiet"
    "splash"
    "loglevel=3"        # Показывать только ошибки (не info/debug)
    "vt.global_cursor_default=0"  # Скрыть мигающий курсор
  ];

  # Дополнительные настройки модулей
  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
    options nvidia NVreg_EnableGpuFirmware=1
  '';

  # ==============================================================
  # 🖼️ Принудительно загрузи EDID — чтобы режим не терялся после сна
  # ==============================================================

  services.xserver.config = ''
    # Принудительно используем NVIDIA
    Section "Device"
      Identifier "NVIDIA"
      Driver "nvidia"
      BusID "PCI:1:0:0"  # Замени на свой BusID (см. ниже)  lspci | grep -i nvidia
    EndSection

    # Отключаем Intel Это бессмысленно
    #Section "Device"
    #  Identifier "Intel"
    #  Driver "modesetting"
    #  Option "AccelMethod" "none"
    #EndSection

    Section "Screen"
      Identifier "Default Screen"
      Device "NVIDIA"
    EndSection
  '';



  # ==============================================================
  # 🖼️ МОНИТОР И EDID (DisplayPort)
  # ==============================================================

  # Подключение бинарного EDID для корректного определения 4K@144Hz
  environment.etc."edid/dp-edid.bin".source =
    let edidFile = ./dp-edid.bin;
    in if builtins.pathExists edidFile
       then edidFile
       else abort "EDID file not found: ${toString edidFile}";

  # Переменные окружения для NVIDIA (важно для Wayland и Vulkan)
  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    WLR_NO_HARDWARE_CURSORS = "1";  # Курсор в Wayland
  };




  #===============================================================
  # 🖼️ Автоперезапуск XWayland после пробуждения
  # ==============================================================

  systemd.services.restart-xwayland-after-sleep = {
    description = "Restart XWayland after resume from suspend";

    # Запускаем ДО сна
    before = [ "sleep.target" ];

    # systemd вызовет script с $1 = post после пробуждения
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StopWhenUnneeded = true;
    };

    script = ''
      case "$1" in
        post)
          echo "Restarting XWayland after resume..." >> /tmp/xwayland-restart.log
          sleep 3
          # Убиваем XWayland — KWin перезапустит его
          pkill -u $(id -u) -f Xwayland
          # Можно добавить задержку, если нужно
          sleep 1
          ;;
      esac
    '';
  };



  # ==============================================================
  # 🖱️ X SERVER И ВИДЕО
  # ==============================================================

  services.xserver = {
    enable = true;
    videoDriver = "nvidia";

    # Раскладка клавиатуры: US + RU, переключение Ctrl+Shift
    xkb.layout = "us,ru";
    xkb.options = "grp:ctrl_shift_toggle";
  };

  # Поддержка тачпада и мыши
  services.libinput.enable = true;


  # ==============================================================
  # 🖼️ РАБОЧИЙ СТОЛ: PLASMA 6 + SDDM
  # ==============================================================

  # Включить KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Включить менеджер входа SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Разрешить Wayland-сессии

  };

  # Включить менеджер входа альтернатива SDDM
#  services.displayManager.lightdm = {
#    enable = true;
#    wayland.enable = true;  # Разрешить Wayland-сессии
#    greeters.slick.enable = true;
#  };

  # ==============================================================
  # 📦 ПАКЕТЫ
  # ==============================================================

  environment.systemPackages = with pkgs; [
    # Текстовые редакторы и языки программирования
    git
    vim
    neovim
    python3
    nodejs
    rustc
    cargo
    notepadqq


    # Утилиты
    wget
    alacritty
    wayland-utils
    edid-decode
    mesa-demos
    curl
    unzip
    strace
    ltrace

    ntfs3g # Или, если хочешь использовать `ntfs-3g` (лучше для записи)

    # GUI
    lxqt.lxqt-sudo
    gnome-system-monitor

    # NVIDIA
    nvtopPackages.nvidia
    pciutils
    nvidia-vaapi-driver

    # Видео проигрователь
    libva-utils
    ffmpeg-full
    mpv

    terminus_font # Шрифт кирилица для tty

    # 🧰 Инструменты для сборки (если будешь компилировать эффекты)
    cmake
    gnumake
    pkg-config
    stdenv.cc


    # сборщик пакетов
    nix
    stdenv




     # 🎨 Темы и кастомизация
    kdePackages.qtstyleplugin-kvantum
    kdePackages.kwin
    kdePackages.kwindowsystem
    kdePackages.plasma-workspace

    # Для управления Plasma
    kdePackages.plasma-workspace
    psmisc  # содержит killall

    # Qt и KDE
    qt6.qtbase
    qt6.qttools
    xorg.libX11
    xorg.libxcb
    libepoxy
    kdePackages.kdeplasma-addons
    kdePackages.systemsettings

    # Браузер
    firefox
    vivaldi
  ];


  # ==============================================================
  # 👤 ПОЛЬЗОВАТЕЛИ
  # ==============================================================

  users.users.safe = {
    isNormalUser = true;
    description = "Основной пользователь";
    extraGroups = [ "video" "input" "wheel" ];
  };


  # ==============================================================
  # ⚙️ АППАРАТНЫЕ НАСТРОЙКИ CPU
  # ==============================================================

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


  # ==============================================================
  # 📦 ВЕРСИЯ СИСТЕМЫ
  # ==============================================================

  system.stateVersion = "25.05";  # Требуется для NixOS 25.05
}
