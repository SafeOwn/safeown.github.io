# ========================================
# 📄 /etc/nixos/configuration.nix
# Основной конфигурационный файл NixOS
# Здесь настраивается:
# - Службы (network, printing, dbus)
# - Пользователи
# - Шрифты
# - Nix
# - Локализация
# - X11 / Видео
# - Безопасность
# - Состояние системы
#
# ВАЖНО: Не удаляйте этот файл. Он управляется Nix.
# ========================================

{ pkgs, inputs, lib, stateVersion, ... }:

let
   # ✅ Импортируем нужные компоненты из pkgs
  stdenv = pkgs.stdenv;
  writeShellScriptBin = pkgs.writeShellScriptBin;

  # 🖼️ Обои в Nix Store (доступны всегда)
  lockscreen-wallpaper = pkgs.runCommand "lockscreen-wallpaper" {} ''
    cp ${./home/wallpaper/lockscreen-wallpaper.jpg} $out
  '';

  # 🍷 LuxWine — обёртка
  luxwine = (import ./home/luxwine/luxwine.nix {
    stdenv = pkgs.stdenv;
  });
in
{

  # ========================================
  # 📦 Импортируемые модули
  # Подключаем внешние .nix файлы с настройками
  # ========================================
  imports = [
    ./modules/boot-disk.nix            # 🔧 Настройка диска и загрузчика (systemd-boot)
    ./modules/hardware/mount.nix                # 🔧 Монтирование моих дисков
    ./modules/hardware/cpu-gpu.nix              # 💻 Настройка CPU, GPU, драйверов NVIDIA
    (import ./modules/hardware/keyboard-touchpad.nix { inherit pkgs; })    # ⌨️ Настройка клавиатуры и тачпада
    ./modules/hardware/audi-bluetooth.nix       # 🔊 Аудио, Bluetooth, PipeWire
    ./modules/hardware/networks.nix             # 🌐 Сеть: NetworkManager, firewall
    ./overlay_unstable.nix                      # 🧪 Overlay: nixpkgs-unstable
    ./overlay_stable.nix                        # 🧱 Overlay: nixpkgs-stable
    ./modules/users/root.nix                    # 🔧 Алиасы и bash т.д. для root
    ./modules/hardware/smb.nix                  # 🌐 Настройка локальной сети
    ./modules/hardware/openrgb.nix              # 🧱 Настройка подсветки
#    ./modules/app/rustdesk.nix                # Не работает только через flatpak
    ./modules/app/flatpak.nix
##     ./modules/hardware/ds4drv.nix
    #./modules/zapret-discord-youtube.nix
  ];

#   services.zapret-discord-youtube = {
#     enable = true;
#     interface = "enp5s0";
#     strategy = "general_alt2.bat";
#   };

  # ========================================
  # 🖥️ Платформа по умолчанию
  # Указываем архитектуру. Обычно не нужно, но может использоваться в overlay
  # ========================================
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ========================================
  # ⚙️ Службы (services)
  # Здесь настраиваются системные сервисы
  # ========================================
  services = {
    # ✅ Оставлено: D-Bus — система межпроцессного взаимодействия
    # Используется всеми DE: KDE, GNOME, XFCE
    dbus.implementation = "broker";

    # ✅ Оставлено: transmission — торрент-клиент с веб-интерфейсом
    transmission = {
      enable = true;
      user = "safe";                    # Пользователь, от которого запускается
      group = "users";                  # Группа
      home = "/home/safe";              # Домашняя директория
      downloadDirPermissions = "775";   # Права на папку загрузок
      settings = {
        incomplete-dir = "/home/safe/Torrent";  # Куда складывать незавершённые
        download-dir = "/home/safe/Torrent";    # Куда складывать готовые
      };
    };

    # ✅ Оставлено: printing — CUPS, принтеры
    printing.enable = true;
  };

  # ========================================
  # 🧹 Удаление ~/.config ПЕРЕД home-manager
  # Используем systemd.services — кастомный юнит
  # ========================================
#   systemd.services.remove-safe-config = {
#     description = "Удаляем /home/safe/.config перед home-manager";
#
#     # Запускается до home-manager
#     before = [ "home-manager-safe.service" ];
#     after = [ "multi-user.target" ];
#
#     # Автоматически включается через wantedBy
#     wantedBy = [ "multi-user.target" ];
#
#     serviceConfig = {
#       Type = "oneshot";
#       RemainAfterExit = true;
#       ExecStart = ''
#         if id safe >/dev/null 2>&1; then
#           echo "🗑️ Удаляем /home/safe/.config..."
#           rm -rf /home/safe/.config
#           mkdir -p /home/safe/.config
#           chown safe:safe /home/safe/.config
#           chmod 700 /home/safe/.config
#           echo "✅ Готово"
#         fi
#       '';
#       User = "root";
#       PermissionsStartOnly = true;
#     };
#   };


  # ========================================
  # 🖥️ Масштабирование GUI (экраны 4K)
  # Переменные окружения для Qt, GTK, Electron
  # ========================================
#   services.xserver.displayManager.sessionCommands = ''
#     # Общее масштабирование
#     export GDK_SCALE="2"
#     export GDK_DPI_SCALE="0.9"
#     export QT_SCALE_FACTOR="2"
#     export QT_FONT_DPI="192"
#
#     # Для Electron (Discord, VS Code)
#     export CHROME_DEVICE_SCALE_FACTOR="2"
#     export ELECTRON_OZONE_PLATFORM_HINT="auto"
#
#     # Для Wayland + NVIDIA
#     export NIXOS_OZONE_WL="1"
#
#     # Принудительно для Wine (если нужно)
#     export WINEDPI="192"   # 192 = 2x от 96 (стандартного DPI)
#   '';


  # ========================================
  # 🎨 Шрифты
  # Установка шрифтов и настройка fontconfig
  # ========================================
  fonts = {
    enableDefaultPackages = true;  # Включить стандартные шрифты (DejaVu и др.)

    packages = with pkgs; [
      noto-fonts          # ✅ Обязательно — полная поддержка кириллицы
      dejavu_fonts        # ✅ Надёжный fallback
      liberation_ttf      # ✅ Замена Arial/Times с кириллицей

      nerd-fonts.jetbrains-mono   # JetBrains Mono с иконками (Nerd Fonts)
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" "Noto Serif" ];
        sansSerif = [ "DejaVu Sans" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" "DejaVu Sans Mono" ];
      };
    };
  };

  # ========================================
  # 📦 Nix — настройки пакетного менеджера
  # Включает flakes, кэши, GC и пути
  # ========================================
  nix = {
    # Включить experimental-features для flakes и nix command
    extraOptions = "experimental-features = nix-command flakes";

    # ❌ Закомментировано: отключение substituters (компилировать всё из исходников)
    # #nix.settings.substituters = lib.mkForce [ ];

    # Отключить каналы (nix-channel), чтобы не мешали flakes
    channel.enable = false;

    # Сборка мусора (удаление старых generations)
    gc = {
      automatic = true;             # Автоматически чистить
      dates = "weekly";             # Раз в неделю
      options = "--delete-older-than 5d";  # Удалять сборки старше 5 дней
    };

    # Настройки Nix
    settings = {
      auto-optimise-store = true;   # Оптимизация хранилища (сжатие ссылок)

      # 🔗 Binary caches (ускоряют установку)
      substituters = [
        "https://nix-community.cachix.org/  "
        "https://chaotic-nyx.cachix.org/  "
        "https://yazi.cachix.org  "
        "https://ghostty.cachix.org  "
        "https://wezterm.cachix.org  "
        # "https://wezterm-nightly.cachix.org  "
      ];

      # 🔐 Доверенные ключи (чтобы Nix принимал пакеты из кэшей)
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        # "wezterm-nightly.cachix.org-1:zsTr51TeTCRg+bHwUr0KfW3XIIb7Avisrj/hXwVzC2c="
      ];
    };

    # Путь для поиска пакетов: nixpkgs из flake
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # 🔁 Закомментировано: ручное управление registry (не нужно при flakes)
    # registry = ...
  };

  # ========================================
  # 🕰️ Часовой пояс
  # ========================================
  # Ручная настройка RTC: считаем, что часы идут по UTC
  system.activationScripts.adjtime.text = ''
    echo "0.0 0 0.0" > /etc/adjtime
    echo "0" >> /etc/adjtime
    echo "UTC" >> /etc/adjtime
  '';
  time.timeZone = "Europe/Moscow";

  # ========================================
  # 🌍 Локализация и язык
  # ========================================
  i18n.supportedLocales = [
    "ru_RU.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  # Язык по умолчанию
  i18n.defaultLocale = "ru_RU.UTF-8";

  environment.sessionVariables = {
    LANG = "ru_RU.UTF-8";
    LC_ALL = "ru_RU.UTF-8";
    LC_MESSAGES = "ru_RU.UTF-8";
  };

  # ========================================
  # 👤 Пользователи
  # Создание пользователя 'safe'
  # ========================================
  virtualisation.libvirtd.enable = true;   # Виртуализация через libvirt
  virtualisation.waydroid.enable = true;   # Android-эмулятор Waydroid
  virtualisation.docker.enable = true;     # Docker

  users.groups.fuse = {};                  # Группа для FUSE
  users.groups.transmission = {};          # Группа для Transmission

  users.users.safe = {
    isNormalUser = true;      # Обычный пользователь (не root)
    # initialPassword = "";   # Пароль устанавливается через `passwd`
    home = "/home/safe";      # Домашняя директория
    description = "safe";     # Имя
    extraGroups = [
      "video"                 # Доступ к GPU
      "wheel"                 # Возможность использовать sudo
      "transmission"          # Доступ к торрент-клиенту
      "fuse"                  # Включить модуль ядра fuse
      "libvirtd"
      "docker"
      "input"
    ];
  };

  # ========================================
  # 🔐 Безопасность: настройка sudo для пользователя safe
  # ========================================
  security.sudo = {
    enable = true;
    # Пользователь safe может выполнять sudo без пароля
    wheelNeedsPassword = false;

    # Дополнительные правила
    extraConfig = ''
      # Запоминать пароль на 60 минут (вместо 5 по умолчанию)
      Defaults timestamp_timeout=60

      # (Опционально) Разрешить safe выполнять любые команды без пароля
      safe ALL=(ALL) NOPASSWD: ALL

      safe ALL=(ALL) NOPASSWD: ${pkgs.kdePackages.kate}/bin/kate /etc/nixos/*
      safe ALL=(ALL) NOPASSWD: ${pkgs.nano}/bin/nano /etc/nixos/*
      safe ALL=(ALL) NOPASSWD: ${pkgs.nixos-install-tools}/bin/nixos-rebuild switch *
    '';
  };

  security.rtkit.enable = true;     # RealtimeKit — приоритет для аудио

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (subject.user !== "safe") {
            return;
        }

        // Логируем для отладки
        // polkit.log("POLKIT: action.id = " + action.id);

        // Разрешить сохранение файлов в /etc/nixos/
        if (action.id === "org.kde.ktexteditor6.katetextbuffer.savefile") {
            var path = action.lookup("path");
            if (path !== null && path.indexOf("/etc/nixos/") === 0) {
                // polkit.log("POLKIT: GRANTED savefile for " + path);
                return polkit.Result.YES;
            }
        }

        // Разрешить переименование/удаление
        if (action.id === "org.kde.ktexteditor6.katetextbuffer.deletefile" ||
            action.id === "org.kde.ktexteditor6.katetextbuffer.renamefile") {
            var path = action.lookup("path");
            if (path !== null && path.indexOf("/etc/nixos/") === 0) {
                return polkit.Result.YES;
            }
        }
    });
  '';

  system.activationScripts.fixNixosPermissions = {
  text = ''
    chmod -R g+w /etc/nixos/
    chgrp -R wheel /etc/nixos/
  '';
  deps = [ "users" ];
};


  # ========================================
  # 🖼️ X Server (графическая подсистема)
  # Настройка дисплея, клавиатуры, драйверов
  # ========================================
  services.xserver = {
    enable = true;            # Включить X11
    videoDriver = "nvidia";   # Драйвер NVIDIA

    # 🔤 Раскладка клавиатуры: US + RU, переключение Ctrl+Shift
    xkb.layout = "us,ru";
    xkb.options = "grp:ctrl_shift_toggle";
  };

  # ==============================================================
  # 🖼️ РАБОЧИЙ СТОЛ: PLASMA 6 + SDDM
  # ==============================================================
  services.desktopManager.plasma6 = {
    enable = true;            # ✅ Включить KDE Plasma 6
  };

  services.displayManager.sddm = {
    enable = true;            # ✅ Включить SDDM (менеджер входа KDE)
    wayland.enable = true;    # ✅ Разрешить сессии Wayland (если нужно)
    theme = "breeze";
  };

  services.displayManager.autoLogin.enable = true;   # Автоматический вход без пароль закомментировать, для отключения
  services.displayManager.autoLogin.user = "safe";   # Автоматический вход без пароль закомментировать, для отключения


  # ========================================
  # 🔐 SDDM — экран входа (до входа пользователя)
  # ========================================
  environment.etc."profiles/lux-wine".text = ''
    export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"
  '';

  # Добавляем theme.conf.user в системные пакеты
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background = ${lockscreen-wallpaper}
    '')
   # luxwine
    pkgs.fuse
    pkgs.appimage-run

    # 📁 Создание .directory и .menu для Lux Wine в меню приложений
    (pkgs.writeTextDir "share/desktop-directories/lux-wine.directory" ''
      [Desktop Entry]
      Type=Directory
      Name=Lux Wine
      Name[ru_RU]=Lux Wine
      Icon=wine
    '')
    (pkgs.writeTextDir "share/desktop-menus/lux-wine.menu" ''
      <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
      <Menu>
        <Name>Lux Wine</Name>
        <Directory>lux-wine.directory</Directory>
        <Include>
          <Category>LuxWine</Category>
        </Include>
      </Menu>
    '')

  ];

  # ========================================
  # 🔐 FUSE Распаковщик
  # ========================================

  # ✅ Разрешить пользователям использовать FUSE
  security.pam.services.fuse = {};  # разрешает FUSE через PAM

  services.dbus.packages = [ pkgs.waydroid ];
  # ✅ Включить модуль ядра fuse
  boot.kernelModules = [ "fuse" "binder_linux" "ashmem_linux" ];


  security.wrappers.fusermount = {
    source = "${pkgs.fuse}/bin/fusermount";
    owner = "root";
    group = lib.mkForce "wheel";  # ← Силой задаём группу, игнорируя дефолтное "root"
    setuid = true;
  };

  environment.pathsToLink = [ "/bin" ];  # чтобы /bin/mount существовал

  # ✅ Включить `user_allow_other` в FUSE
  systemd.services."proc-sys-fs-binfmt_misc".after = [ "sys-fs-fuse-connections.mount" ];
  boot.kernel.sysctl."fs.suid_dumpable" = 0;
  boot.kernel.sysctl."fs.file-max" = 1048576;

  # Добавим явно разрешение на использование FUSE
  environment.etc."fuse.conf".text = ''
    # Разрешить пользователям использовать allow_other
    user_allow_other
  '';

  # ==============================================================
  # 📦 nix-ld — минимальная среда для .AppImage, .deb, .rpm
  # Только для запуска сторонних бинарников, НЕ для игр
  # Все игровые зависимости — в cpu-gpu.nix
  # ==============================================================
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Системные библиотеки
      glibc                         # Стандартная библиотека C — основа всех программ в Linux
      stdenv.cc.cc                  # Системный компилятор (обычно GCC или Clang) — нужен для динамической линковки
      zlib                          # Библиотека сжатия данных (используется почти везде: PNG, gzip, и др.)
      libx11                        # Базовая библиотека X11 — для взаимодействия с графической подсистемой
      libxext                       # Расширения X11 (Shape, XTest, и др.)
      xorg.libXrender               # Поддержка аппаратного рендеринга в X11 (сглаживание, альфа-каналы)
      libxcb                        # Современная низкоуровневая библиотека для X11 (альтернатива Xlib)
      xorg.libXcursor               # Управление курсорами мыши в X11
      xorg.libXi                    # Расширение ввода X11 (мульти-клавиатура, геймпады, планшеты)
      libxkbcommon                  # Обработка раскладок клавиатуры (Wayland/X11), особенно для Qt/Wayland
      mesa                          # OpenGL-совместимый драйвер рендеринга (для GPU)
      fontconfig                    # Настройка и выбор шрифтов в системе
      freetype                      # Рендеринг шрифтов (работает в паре с fontconfig)
      glib                          # Утилиты GLib — основа для GTK, GNOME и многих приложений
      pulseaudio                    # Звуковая система PulseAudio (даже если используется PipeWire — совместимость)
      openssl                       # Криптография, TLS/SSL — для HTTPS, безопасных соединений
      zstd                          # Современный алгоритм сжатия (быстрее gzip, лучше сжатие)
      krb5                          # Kerberos 5 — аутентификация в корпоративных сетях

      # Только Qt6 через kdePackages — НИЧЕГО другого Qt не добавляй!
      kdePackages.qtbase            # Ядро Qt6 — основные классы, GUI, события, виджеты
      kdePackages.qtdeclarative     # QML и Qt Quick — декларативный UI (для современных Qt-приложений)
      kdePackages.qtmultimedia      # Аудио/видео в Qt — воспроизведение, камеры, микрофоны
      kdePackages.qt5compat         # Совместимость с Qt5 API — для старых приложений

      nss                           # Network Security Services — криптография от Mozilla (Firefox, Thunderbird)
      nspr                          # Netscape Portable Runtime — низкоуровневые системные API для NSS
      atk                           # Accessibility Toolkit — доступность для инвалидов (экранное чтение и др.)
      alsa-lib                      # Низкоуровневый звуковой интерфейс (даже если используется Pulse/PipeWire)
      libxcrypt                     # Современная реализация crypt() — хеширование паролей
      libepoxy                      # Упрощённый OpenGL API — для приложений, использующих OpenGL поверх EGL/GLX
    ];
  };



  # ========================================
  # 📦 Версия состояния системы
  # Важно не менять после установки
  # ========================================
  system.stateVersion = "25.05"; # ← ВАЖНО: не меняйте, если не уверены
}
