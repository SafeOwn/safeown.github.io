# ========================================
# 📦 Системные программы и сервисы
# Здесь включаются отдельные утилиты: Firefox, Zoxide, GPG, и др.
# ========================================
{ config, pkgs, inputs, ... }:
{

  # ========================================
  # 🧩 Программы: Включённые сервисы и утилиты (programs.*)
  # Управление через NixOS-модули (автоматическая интеграция в систему)
  # ========================================
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


  # ========================================
  # 🧬 Nixpkgs: Оверлеи (переопределения пакетов)
  # Нужен для сборки darktable и других пакетов с дополнительными зависимостями
  # ========================================
  nixpkgs.overlays = [
    (final: prev: {
      osm-gps-map = prev.osm-gps-map.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
          final.autoreconfHook   # Автоматическая перегенерация configure-скриптов (autoconf)
          final.automake         # Инструмент для генерации Makefile.in из Makefile.am
          final.libtool          # Утилита для создания переносимых библиотек (shared/static)
          final.perl             # Язык Perl — требуется для скриптов сборки и генерации документации
          final.pkg-config       # Утилита для получения флагов компиляции и линковки зависимостей
          final.gtk-doc          # Система генерации документации для библиотек (особенно GTK/GNOME)
        ];
      });
    })
  ];


  # ========================================
  # 🧰 Пакеты в системном профиле (environment.systemPackages)
  # Все программы, доступные глобально в PATH — отсортированы по категориям
  # ========================================
  environment.systemPackages = with pkgs; [

    # ========================================
    # 🔧 СИСТЕМНЫЕ УТИЛИТЫ — диагностика, железо, мониторинг
    # ========================================
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
    evtest                      # Тест ввода (клавиатура, мышь)
    fastfetch                   # Информация о системе
    btop                        # Мониторинг ресурсов
    gnome-logs                  # Просмотр логов
    edid-decode                 # Декод EDID
    mesa-demos                  # glxgears
    strace                      # Слежение за системными вызовами
    ltrace                      # Слежение за библиотечными вызовами
    psmisc                      # killall
    procps                      # ps, top, free
    file                        # Определение типа файла
    curl                        # curl
    wget                        # Загрузка файлов
    git                         # Git
    nix                         # Nix CLI
    nix-tree                    # Дерево зависимостей Nix
    nix-du                      # Анализ /nix/store
    fdupes                      # Поиск дубликатов
    ncdu                        # Анализ диска
    qdirstat                    # Визуальный анализ диска
    cron                        # Планировщик задач


    # ========================================
    # 🛠 РАЗРАБОТКА — языки, компиляторы, отладчики, LSP
    # ========================================
    gcc                         # C/C++ компилятор
    gnumake                     # make
    cmake                       # Сборка C++
    pkg-config                  # Утилита для сборки
    stdenv.cc                   # Компилятор
    stdenv                      # Окружение сборки

    # Go
    go                          # Язык программирования Go
    gotools                     # Инструменты Go (gotestsum, gotestfmt и др.)
    go-tools                    # Дополнительные утилиты Go (staticcheck, etc.)
    delve                       # Go debugger
    gopls                       # Go LSP
    gofumpt                     # Форматтер Go
    golines                     # gofumpt + многострочный
    golint                      # Линтер Go
    revive                      # Современный линтер Go
    golangci-lint               # Мульти-линтер
    golangci-lint-langserver    # LSP для golangci-lint
    gdlv                        # GUI отладчик Go

    # Python
    python313                   # Python 3.13
    python313Packages.python-lsp-server  # LSP для Python
    python313Packages.python-lsp-ruff    # Интеграция Ruff в LSP
    python313Packages.python-lsp-black   # Интеграция Black в LSP
    python313Packages.debugpy            # Отладчик Python
    ruff                        # Линтер Python
    yapf                        # Форматтер Python

    # Lua
    lua                         # Интерпретатор Lua
    lua-language-server         # LSP для Lua
    stylua                      # Форматтер Lua

    # Rust
    rustc                       # Компилятор Rust
    cargo                       # Менеджер пакетов Rust

    # Zig
    zig                         # Язык Zig
    zls                         # LSP для Zig

    # Node.js
    nodejs                      # JavaScript-среда выполнения

    # Bash / Shell
    bash-language-server        # LSP для Bash
    shfmt                       # Форматтер shell-скриптов

    # Nix
    nil                         # Nix LSP
    nixfmt-rfc-style            # Форматтер Nix (RFC-style)
    alejandra                   # Форматтер Nix (альтернатива)

    # Общие LSP
    vscode-langservers-extracted # CSS, HTML, JSON
    jsonrpc-glib                # Для D-Bus
    taplo                       # TOML LSP
    yaml-language-server        # YAML LSP
    ansible-language-server     # Ansible LSP

    # Отладчики и инструменты
    gdb                         # GNU Debugger
    jq                          # JSON processor
    hexyl                       # hex-дамп с подсветкой


    # ========================================
    # 🌐 СЕТЬ И БЕЗОПАСНОСТЬ — Wi-Fi, снифферы, VPN, MITM
    # ========================================
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
    dnsmasq                     # DNS/DHCP сервер
    openvpn                     # VPN
    bluetuith                   # GUI для Bluetooth
    bluetui                     # TUI для Bluetooth
    impala                      # Bluetooth-менеджер
    ettercap                    # MITM
    reaverwps                   # WPS атаки
    bully                       # WPS атаки
    pixiewps                    # WPS brute
    crunch                      # Генератор словарей
    #cloudflare-warp            # Получить ключи WARP
    #bettercap                  # MITM-атаки


    # ========================================
    # 🖥️ ГРАФИЧЕСКИЕ УТИЛИТЫ — скриншоты, буфер, курсоры, шрифты
    # ========================================
    grim                        # Скриншоты (Wayland)
    wl-clipboard                # Буфер обмена Wayland
    wl-clip-persist             # Постоянный буфер
    notify-desktop              # Уведомления
    satty                       # Цветовая палитра
    bibata-cursors              # Красивые курсоры
    base16-schemes              # Цветовые схемы
    terminus_font               # Шрифт для TTY с кириллицей
    wvkbd                       # Виртуальная клавиатура
    wayland-utils               # wayland-info
    xorg.xwininfo               # Утилита для получения информации об окнах X11
    xorg.libX11                 # Библиотека X11
    xorg.libxcb                 # Библиотека XCB (X protocol C-language Binding)
    libepoxy                    # OpenGL
    qt6.qtbase                  # Базовые библиотеки Qt6
    qt6.qttools                 # Инструменты Qt6 (linguist, designer и др.)


    # ========================================
    # 📁 ФАЙЛОВАЯ СИСТЕМА И ДИСКИ — форматирование, монтирование, управление
    # ========================================
    gparted                     # GUI для управления дисками
    ntfs3g                      # Драйвер NTFS (чтение/запись)
    util-linux                  # mkfs.vfat
    exfatprogs                  # mkfs.exfat
    e2fsprogs                   # mkfs.ext4
    geteltorito                 # Извлечение ISO
    unar                        # Распаковка архивов
    p7zip                       # Архиватор 7-Zip
    zip                         # Утилиты ZIP
    unzip                       # Распаковка ZIP
    rar                         # Архиватор RAR
    unrar                       # Распаковка RAR
    gvfs                        # Виртуальная файловая система
    desktop-file-utils          # Обновление .desktop файлов
    #udiskie                    # Автомонтирование


    # ========================================
    # 🎨 ТЕМЫ И ИНТЕРФЕЙС — KDE, GTK, Plasma, Kvantum
    # ========================================
    kdePackages.breeze          # Тема Breeze для KDE
    kdePackages.breeze-gtk      # Тема Breeze для GTK
    kdePackages.qtstyleplugin-kvantum  # Плагин стиля Kvantum для Qt
    kdePackages.plasma-workspace # Рабочее окружение Plasma
    kdePackages.kconfig         # Библиотека конфигурации KDE
    kdePackages.kde-cli-tools   # CLI-инструменты KDE
    kdePackages.kcharselect     # Выбор символов
    kdePackages.kdbusaddons     # kquitapp5, kstart5
    kdePackages."plasma-systemmonitor" # Системный монитор Plasma


    # ========================================
    # 🖼️ KDE ПРИЛОЖЕНИЯ — офис, мультимедиа, системные утилиты
    # ========================================
    kdePackages.krdc            # Удалённый рабочий стол
    kdePackages.krfb            # VNC-сервер
    kdePackages.k3b             # Запись дисков
    kdePackages.kalk            # Калькулятор
    kdePackages.discover        # Центр приложений
    kdePackages.kinfocenter     # Информация о системе
    kdePackages.kdialog         # Диалоги в скриптах
    kdePackages.gwenview        # Просмотр изображений
    kdePackages.partitionmanager # GUI для управления дисками
    kdePackages.kpmcore         # Обязателен для partitionmanager
    kdePackages.kfind           # Поиск файлов
    kdePackages.kompare         # Сравнение файлов
    kdePackages.kamoso          # Веб-камера
    kdePackages.ktorrent        # Торрент-клиент
    kdePackages.kget            # Загрузчик
    kdePackages.krecorder       # Запись экрана
    kdePackages.kmenuedit       # Редактор меню
    kdePackages.isoimagewriter  # Запись ISO


    # ========================================
    # 🎵 АУДИО И ВИДЕО — плееры, редакторы, эффекты, кодеки
    # ========================================
    mpv                         # Видеоплеер
    vlc                         # Видеоплеер VLC
    ffmpeg                      # Конвертация
    ffmpeg-full                 # Полная версия FFmpeg
    ffmpegthumbnailer           # Миниатюры
    youtube-tui                 # YouTube в терминале
    yt-dlp                      # Загрузка видео
    stremio                     # Стриминг
    video-downloader            # GUI загрузчик видео
    mediainfo                   # Информация о медиафайлах

    # Аудио
    easyeffects                 # Аудиоэффекты
    haruna                      # Аудиоплеер
    audacious                   # Аудиоплеер
    #strawberry                 # Аудиоплеер
    #audacity                   # Аудиоредактор
    wiremix                     # Аудио-микшер
    sayonara                    # Аудиоплеер
    asak                        # Аудио-сканер

    # Видеоредакторы
    obs-studio                  # Стриминг и запись
    avidemux                    # Видеоредактор
    kdePackages.kdenlive        # Видеоредактор (KDE)

    # Фото
    darktable                   # RAW-фотообработка
    krita                       # Рисование и редактирование
    ueberzugpp                  # Просмотр изображений в терминале
    imagemagick                 # Обработка изображений
    upscayl                     # Улучшение изображений ИИ
    xnviewmp                    # Просмотр изображений


    # ========================================
    # 📄 ОФИС И ТЕКСТ — PDF, редакторы, офисные пакеты
    # ========================================
    zathura                     # PDF-ридер
    poppler                     # PDF утилиты (pdftotext)
    onlyoffice-bin              # Офисный пакет
    peazip                      # Архиватор
    okteta                      # HEX-редактор
    bleachbit                   # Очистка системы
    easytag                     # Редактор тегов аудио


    # ========================================
    # 🖋️ ТЕКСТОВЫЕ РЕДАКТОРЫ И IDE
    # ========================================
    vim                         # Текстовый редактор Vim
    neovim                      # Современный Vim
    vscode                      # Visual Studio Code
    github-desktop              # GUI для Git от GitHub
    sublime-merge               # GUI для Git (Sublime)
    #helix                      # Текстовый редактор
    #notepadqq                  # Лёгкий редактор
    #hope                       # Современный редактор


    # ========================================
    # 🎮 ИГРЫ И ЭМУЛЯТОРЫ — консоли, ПК, ретро
    # ========================================
    # Игры
    flare                       # RPG
    zeroad                      # Стратегия

    # Эмуляторы
    pcsx2                       # PlayStation 2
    rpcs3                       # PlayStation 3
    shadps4                     # PlayStation 4
    cemu-ti                     # Wii U
    mgba                        # Game Boy Advance
    snes9x                      # SNES
    fceux-qt6                   # NES
    mupen64plus                 # Nintendo 64
    dolphin-emu                 # GameCube / Wii
    citron                      # Nintendo Switch
    ryubing                     # Nintendo Switch (альтернатива Ryujinx)
    ppsspp-qt                   # PSP
    zsnes2                      # SNES
    bsnes-hd                    # SNES (высокая точность)
    kega-fusion                 # Sega
    scummvm                     # Классические приключенческие игры
    fsuae                       # Amiga
    fsuae-launcher              # Запускатель FS-UAE
    hatari                      # Atari ST
    mame                        # Аркады и консоли
    dosbox-staging              # DOS
    dosbox-x                    # DOS (расширенный)
    xemu                        # Xbox
    x16                         # Commander X16

    # Эмуляторы (через RetroArch — закомментированы)
    #retroarch-full          # Мультиплатформенный фронтенд для эмуляторов (RetroArch)
    #libretro.swanstation    # Эмулятор PlayStation (PS1/PS2) — альтернатива PCSX2
    #libretro.dolphin        # Эмулятор GameCube и Wii (через libretro)
    #libretro.scummvm        # Эмулятор классических приключенческих игр (Monkey Island и др.)
    #libretro.hatari         # Эмулятор Atari ST
    #libretro.mame           # Эмулятор аркадных автоматов и старых консолей (актуальная версия MAME)
    #libretro.gambatte       # Эмулятор Game Boy / Game Boy Color
    #libretro.pcsx2          # Эмулятор PlayStation 2
    #libretro.neocd          # Эмулятор Neo Geo CD
    #libretro.citra          # Эмулятор Nintendo 3DS
    #libretro.snes9x         # Эмулятор Super Nintendo (SNES)
    #libretro.ppsspp         # Эмулятор PlayStation Portable (PSP)
    #libretro.dosbox         # Эмулятор DOS (основан на DOSBox)
    #libretro.sameboy        # Эмулятор Game Boy / Game Boy Color (высокая точность)
    #libretro.mame2015       # Старая версия MAME (2015) — для совместимости с определёнными играми
    #libretro.mame2016       # Старая версия MAME (2016) — баланс между точностью и производительностью

    # Мобильные эмуляторы
    waydroid                    # Запуск Android-приложений
    waydroid-helper             # Вспомогательные утилиты Waydroid
    android-tools               # содержит adb


    # ========================================
    # 🎮 ГЕЙМПАДЫ И КОНТРОЛЛЕРЫ
    # ========================================
    sc-controller               # GUI для настройки контроллеров
    qjoypad                     # Настройка геймпадов как клавиатуры/мыши
    antimicrox                  # Альтернатива qjoypad
    xdotool                     # Эмуляция ввода (мышь/клава)


    # ========================================
    # 🌐 БРАУЗЕРЫ И КОММУНИКАЦИИ — браузеры, мессенджеры, удалённый доступ
    # ========================================
    firefox                     # Веб-браузер Firefox
    chromium                    # Веб-браузер Chromium
    vivaldi                     # Веб-браузер Vivaldi
    floorp                      # Веб-браузер Floorp (форк Firefox)
    telegram-desktop            # Мессенджер Telegram
    discord                     # Мессенджер Discord
    nchat                       # TUI чат
    tdl                         # Telegram CLI
    katana                      # TUI-браузер
    anydesk                     # Удалённый доступ
    #whatsapp-for-linux         # Неофициальный нативный клиент WhatsApp для Linux (устаревший/не поддерживается)
    #zapzap                     # Неофициальный Qt-клиент WhatsApp для Linux, основанный на веб-версии
    altus                       # Альтернативный клиент
    chatgpt-cli                 # CLI для ChatGPT


    # ========================================
    # 📥 ЗАГРУЗЧИКИ И ТОРРЕНТЫ
    # ========================================
    qbittorrent                 # Торрент-клиент qBittorrent
    kdePackages.ktorrent        # Торрент-клиент KDE
    kdePackages.kget            # Загрузчик KDE
    #xdman


    # ========================================
    # 🖥️ ВИРТУАЛИЗАЦИЯ — VM, контейнеры
    # ========================================
    virt-manager                # Менеджер виртуальных машин
    virtualbox                  # VirtualBox


    # ========================================
    # 🔐 КРИПТОГРАФИЯ И БЕЗОПАСНОСТЬ
    # ========================================
    gpg-tui                     # TUI для GPG
    pinentry-tty                # Ввод пароля в терминале
    gpgme                       # GPG API
    #liana                      # Bitcoin кошелёк
    #wasabiwallet               # Bitcoin кошелёк
    clash-verge-rev             # Прокси
    mihomo                      # Прокси (Clash Meta)
    byedpi                      # Обход DPI


    # ========================================
    # 🧩 РАЗНОЕ — утилиты, TUI, игры, инструменты
    # ========================================
    eza                         # Современный ls
    ripgrep                     # rg — быстрый поиск
    fd                          # fd — современный find
    sqlite                      # SQLite CLI
    alacritty                   # Терминал
    dconf                       # Настройки GNOME
    glib                        # Библиотека GLib
    gtk3                        # Библиотека GTK 3
    tray-tui                    # Системный трей
    gtt                         # Таймер
    ttyper                      # Тренажёр печати
    ngrrram                     # Мем-генератор
    tui-journal                 # Журнал в TUI
    lazysql                     # SQL TUI
    nftables                    # Файрволл
    #gpu-viewer                 # GUI для просмотра GPU


    # ========================================
    # 🎨 ГРАФИКА И HDR — Vulkan, Wayland, HDR-игры
    # ========================================
    meson                       # Система сборки Meson
    ninja                       # Быстрая система сборки Ninja
    vulkan-headers              # Заголовки Vulkan API
    vulkan-loader               # Загрузчик Vulkan
    wayland                     # Протокол Wayland
    wayland-protocols           # Протоколы Wayland
    wayland-scanner             # Генератор кода для Wayland
    nvtopPackages.nvidia        # Мониторинг NVIDIA
    nvidia-vaapi-driver         # VA-API для NVIDIA


    # ========================================
    # 🖥️ KDE СИСТЕМНЫЕ УТИЛИТЫ — дополнения Plasma
    # ========================================
    kdePackages.kwallet-pam     # Авторазблокировка кошелька
  ];


  # ========================================
  # 🌍 ЯЗЫКОВЫЕ ПАКЕТЫ — локализация
  # ========================================
  programs.firefox.languagePacks = [ "ru" ];


  # ========================================
  # 🧱 Пакеты из стабильного канала (nixpkgs-stable)
  # Используется для критичных пакетов: WezTerm, Zathura и др.
  # ========================================
}
