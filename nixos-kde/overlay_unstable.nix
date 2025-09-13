# ========================================
# 📦 Системные программы и сервисы
# Здесь включаются отдельные утилиты: Firefox, Zoxide, GPG, и др.
# ========================================
{ config, pkgs, inputs, ... }:
{

  programs = {
    # ✅ Оставлено: Firefox
    firefox.enable = true;

    # ✅ Оставлено: AmneziaVPN
    amnezia-vpn.enable = true;

    # ✅ Оставлено: Zoxide — умный навигатор по директориям
    zoxide.enable = true;

    # ✅ Оставлено: GPG + pinentry
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
      # pinentryPackage = pkgs.pinentry-tty;  # раскомментируйте, если хотите tty
    };
  };

  nixpkgs.overlays = [  # Нужен для darktable
    (final: prev: {
      osm-gps-map = prev.osm-gps-map.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
          final.autoreconfHook
          final.automake
          final.libtool
          final.perl
          final.pkg-config
          final.gtk-doc
        ];
      });
    })
  ];



  # ========================================
  # 🧰 Пакеты в системном профиле (nix-env -i)
  # Все программы, доступные глобально в PATH
  # ========================================
  environment.systemPackages = with pkgs; [
    # 🔧 Утилиты диагностики и системные
    mtr                          # Сетевой диагноз (ping + traceroute)
    systemctl-tui               # TUI для управления systemd
    powertop                    # Анализ энергопотребления
    pciutils                    # lspci
    usbutils                    # lsusb
    smartmontools               # S.M.A.R.T. для дисков
    nvme-cli                    # Управление NVMe
    libva-utils                 # vainfo
    inxi                        # Информация о системе
    brightnessctl               # Управление яркостью
    dmidecode                   # Информация о BIOS/оборудовании
    ripgrep                     # rg — быстрый поиск
    fd                          # fd — современный find
    evtest                      # Тест ввода (клавиатура, мышь)
    eza                         # Современный ls
    sqlite                      # SQLite CLI
   # gpu-viewer                  # GUI для просмотра GPU

    # 🛠 Программирование
    gcc                         # C/C++ компилятор
    gnumake                     # make
    go                          # Go
    gotools                     # go-tools
    go-tools                    # Альтернативный пакет
    delve                       # Go debugger
    gopls                       # Go LSP
    gofumpt                     # Форматтер Go
    golines                     # gofumpt + многострочный
    golint                      # Линтер Go
    revive                      # Современный линтер Go
    golangci-lint               # Мульти-линтер
    golangci-lint-langserver  # LSP для golangci-lint
    gdlv                        # GUI отладчик Go
    gdb                         # GNU Debugger
    zig                         # Язык Zig
    zls                         # Zig Language Server
    bash-language-server        # LSP для bash
    shfmt                       # Форматирование shell
    python313                   # Python 3.13
    python313Packages.python-lsp-server  # pylsp
    python313Packages.python-lsp-ruff
    python313Packages.python-lsp-black
    python313Packages.debugpy   # Python debugger
    ruff                        # Линтер Python
    yapf                        # Форматтер Python
    lua                         # Lua
    lua-language-server         # LSP для Lua
    stylua                      # Форматтер Lua
    taplo                       # TOML LSP
    yaml-language-server        # LSP для YAML
    ansible-language-server     # LSP для Ansible
    vscode-langservers-extracted # Общие LSP (CSS, HTML, JSON)
    jsonrpc-glib                # Для D-Bus
    jq                          # JSON processor
    nil                         # Nix LSP
    nixfmt-rfc-style            # Форматирование Nix
    alejandra                   # Альтернативный форматтер Nix
    hexyl                       # hex-дамп с подсветкой

    # 🌐 Сеть и безопасность
    iw                          # Управление Wi-Fi
    aircrack-ng                 # Взлом Wi-Fi (pentest)
    wirelesstools               # iwconfig и др.
    airgeddon                   # Wi-Fi аудит
    termshark                   # TUI для Wireshark
    sniffnet                    # Анализ трафика
    nmap                        # Сканирование портов
    tor                         # Анонимный доступ
    wifite2                     # Автоматизация атак на Wi-Fi
    kismet                      # Радио-сниффер
    hcxtools                    # Хакинг WPA
    hcxdumptool                 # Дамп хендшейков
    hostapd                     # Точка доступа
    dhcpdump                    # Анализ DHCP
    lighttpd                    # Лёгкий веб-сервер
    #bettercap                   # MITM-атаки
    dnsmasq                     # DNS/DHCP сервер
    openvpn                     # VPN
    bluetuith                   # GUI для Bluetooth
    bluetui                     # TUI для Bluetooth
    impala                      # Bluetooth-менеджер
    wget                        # Загрузка файлов
    git                         # Git
    #cloudflare-warp             # Получить ключи WARP

    # 🌐 Браузеры и коммуникации
    chromium                    # Chromium
    telegram-desktop            # Telegram
    rustmission                 # Инструменты (возможно, опечатка)
    reaverwps                   # WPS атаки
    bully                       # WPS атаки
    pixiewps                    # WPS brute
    crunch                      # Генератор словарей
    ettercap                    # MITM
    nchat                       # TUI чат
    tdl                         # Telegram CLI
    katana                      # TUI-браузер

    # 🔐 Крипто
    gpg-tui                     # TUI для GPG
    pinentry-tty                # Ввод пароля в терминале
    gpgme                       # GPG API
    #liana                       # Bitcoin кошелёк
    #wasabiwallet                # Bitcoin кошелёк

    # 🧰 Утилиты
    gparted                     # GUI для управления дисками
    geteltorito                 # Извлечение ISO
    fastfetch                   # Информация о системе
    btop                        # Мониторинг ресурсов
    gnome-logs                  # Просмотр логов
    satty                       # Цветовая палитра
    grim                        # Скриншоты (Wayland)
    chatgpt-cli                 # CLI для ChatGPT
    gtt                         # Таймер
    ttyper                      # Тренажёр печати
    ngrrram                     # Мем-генератор
    tui-journal                 # Журнал в TUI
    nix-tree                    # Дерево зависимостей Nix
    lazysql                     # SQL TUI
    tray-tui                    # Системный трей
    gvfs                        # Виртуальная файловая система
    nftables
    procps

    # 🎵 Медиа
    asak                        # Аудио-сканер
    mpv                         # Видеоплеер
    ffmpeg                      # Конвертация
    ffmpegthumbnailer           # Миниатюры
    youtube-tui                 # YouTube в терминале
    yt-dlp                      # Загрузка видео
    ueberzugpp                  # Просмотр изображений в терминале
    imagemagick                 # Обработка изображений
    wiremix                     # Аудио-микшер

    # 📄 Офис и редакторы
    poppler                     # PDF утилиты (pdftotext)
    #abiword                     # Лёгкий текстовый редактор
    zathura                     # PDF-ридер
    #helix                       # Текстовый редактор
    unar                        # Распаковка архивов
    p7zip                       # 7z
    zip                         # zip
    unzip                       # unzip
    rar                         # rar
    unrar                       # unrar

    # 🎨 Темы и курсоры
    bibata-cursors              # Красивые курсоры
    base16-schemes

    # 🧩 Разное
    dconf                       # Настройки GNOME
    glib                        # Библиотека GLib
    gtk3
    notify-desktop              # Уведомления
    wvkbd                       # Виртуальная клавиатура
    wl-clipboard                # Буфер обмена Wayland
    wl-clip-persist             # Постоянный буфер
    #udiskie                     # Автомонтирование
    alacritty                   # Терминал
    wayland-utils               # wayland-info
    edid-decode                 # Декод EDID
    mesa-demos                  # glxgears
    curl                        # curl
    strace                      # Слежение за системными вызовами
    ltrace                      # Слежение за библиотечными вызовами
    terminus_font               # Шрифт для TTY с кириллицей
    cmake                       # Сборка C++
    pkg-config                  # Утилита для сборки
    stdenv.cc                   # Компилятор
    nix                         # Nix CLI
    stdenv                      # Окружение сборки
    psmisc                      # killall
    qt6.qtbase                  # Qt6 база
    qt6.qttools                 # Qt6 инструменты
    xorg.libX11                 # X11
    xorg.libxcb                 # XCB
    libepoxy                    # OpenGL

    firefox                     # Firefox
   # firefox-i18n-ru  # Язык русский
    qbittorrent

    vivaldi                     # Браузер
    anydesk                     # Удалённый доступ
    #whatsapp-for-linux          # WhatsApp
    #zapzap                      # WhatsApp
    altus                       # Альтернативный клиент
    nix-ld                      # Запуск бинарников с Nix
    #nerdfonts                   # Nerd Fonts
    vim                         # Vim
    neovim                      # Neovim
    python3                     # Python 3.12
    python3Packages.flask       # Flask
    python3Packages.pyqt5       # PyQt5
    nodejs                      # Node.js
    rustc                       # Rust
    cargo                       # Cargo
    #notepadqq                   # Лёгкий редактор
    #hope                        # Современный редактор

    # 🖼️ KDE Plasma 6 и приложения
    kdePackages."plasma-systemmonitor"  # ← Мониторинг системы

    ntfs3g                      # mkfs.ntfs Драйвер NTFS (чтение/запись)
    util-linux  # mkfs.vfat
    exfatprogs  # mkfs.exfat
    e2fsprogs   # mkfs.ext4

    kdePackages.breeze-gtk             # Тема Breeze для GTK-приложений
    kdePackages.breeze
    kdePackages.qtstyleplugin-kvantum  # Kvantum для Qt
    kdePackages.kwallet-pam            # Авторазблокировка кошелька
    kdePackages.krdc                   # Удалённый рабочий стол
    kdePackages.krfb                   # VNC-сервер
    kdePackages.k3b                    # Запись дисков
    #kdePackages.kcalc                 # Калькулятор
    kdePackages.kalk                   # Калькулятор Win
    kdePackages.discover               # Центр приложений
    kdePackages.kinfocenter            # Информация о системе
    kdePackages.kdialog                # Диалоги в скриптах
    kdePackages.gwenview               # Просмотр изображений
    kdePackages.plasma-workspace
    kdePackages.qtstyleplugin-kvantum  # Поддержка кастомных стилей Kvantum для Qt-приложений
    kdePackages.kconfig
    kdePackages.partitionmanager       # GUI для управления дисками
    kdePackages.kpmcore   # ← ЭТОТ ПАКЕТ ОБЯЗАТЕЛЬНО ДЛЯ partitionmanager
    kdePackages.kde-cli-tools

    # HDR games
    meson
    ninja
    vulkan-headers
    vulkan-loader
    wayland
    wayland-protocols
    wayland-scanner
    wayland-utils
    xorg.xwininfo


    kdePackages.kdbusaddons   # содержит kquitapp5, kstart5


    # 📺 Видео и кодеки
    nvtopPackages.nvidia               # Мониторинг NVIDIA
    nvidia-vaapi-driver                # VA-API для NVIDIA
    ffmpeg-full                        # Полная версия FFmpeg
    stremio


    p7zip
    xdotool

    # Геймпад
    qjoypad
    antimicrox
    sc-controller     # ✅ GUI для настройки контроллеров




    video-downloader
    #audacity
    vlc
    onlyoffice-bin
    krita

    darktable




    kdePackages.kdenlive
    #strawberry
    audacious
    obs-studio
    stacer
    discord
    floorp
    hardinfo2
    cpu-x
    sniffnet
    #xdman
    easyeffects
    haruna

    desktop-file-utils



    virt-manager
    virtualbox



   # tribler
    vscode


    mediainfo

    peazip
    xnviewmp
    kdePackages.isoimagewriter
    kdePackages.kfind
    kdePackages.kompare
    kdePackages.kamoso
    kdePackages.ktorrent
    kdePackages.kget
    kdePackages.krecorder
    kdePackages.kmenuedit

    okteta
    bleachbit


    filezilla
    sublime-merge

    github-desktop
    upscayl

    fdupes   # для поиска дубликатов
    ncdu     # для анализа диска
    nix-du   # для анализа /nix/store
    cron
    qdirstat




    flare   # игра rpg
    zeroad  # стратегия



    waydroid
    waydroid-helper
    android-tools # содержит adb

    # Эмуляторы приставок
    #emulationstation-de
    hydralauncher
    #pegasus-frontend

    #epsxe
    pcsx2
    rpcs3
    shadps4
    cemu-ti
    mgba

    snes9x
    fceux-qt6

    mupen64plus
    dolphin-emu
    citron


    #ryujinx только в nixos 25.05
    ryubing


    ppsspp-qt
    zsnes2


    kega-fusion
    scummvm

    fsuae
    fsuae-launcher

    hatari
    mame
    dosbox-staging
    xemu
    x16


    #retroarch-full
    #libretro.swanstation #duckstation for retroarch
    #libretro.dolphin
    #libretro.scummvm
    #libretro.hatari
    #libretro.mame
    #libretro.gambatte
    #libretro.pcsx2
    #libretro.neocd
    #libretro.citra
    #libretro.snes9x
    #libretro.ppsspp
    #libretro.dosbox
    #libretro.sameboy
    #libretro.mame2015
    #libretro.mame2016


  ];


  programs.firefox.languagePacks = [ "ru" ];
  # ========================================
  # 🧱 Пакеты из стабильного канала (nixpkgs-stable)
  # Используется для критичных пакетов: WezTerm, Zathura и др.
  # ========================================
} 

