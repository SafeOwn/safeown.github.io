# ========================================
# 🏠 home.nix — Конфигурация home-manager
# Управляет: пользовательскими пакетами, shell, GUI-приложениями, dot-файлами
# Работает с любым DE/WM: KDE, GNOME, Hyprland и др.
# ========================================
{ lib, config, pkgs, osConfig, lockscreen-wallpaper, ... }:


{
  # ========================================
  # 📦 Импорты модулей home-manager
  # Подключает конфигурации отдельных программ
  # ========================================
  imports = [
    ./home/firefox.nix
    ./home/fastfetch.nix
    ./home/eza.nix
    ./home/zoxide.nix
    ./home/btop.nix
    #./home/mpv.nix
    ./home/gpg.nix
    ./modules/users/user.nix
    ./home/wallpaper/wallpaper.nix

    # 🍷 WINE
   # ./home/wine/wine.nix #   # 🍷 Подключаем модуль Wine
    #./home/wine/lutris.nix
   # ./home/wine/game/quake3.nix
  ];

#     programs.wine.enable = true;
#     programs.wine.winePrefix = "$HOME/.wine";
#
#     programs.lutris.enable = true;

  # ========================================
  # 👤 Пользователь и домашняя директория
  # Указывается имя пользователя и путь к домашней папке
  # ========================================
  home.username = "safe";
  home.homeDirectory = "/home/safe";

  # Включает интеграцию home-manager в bash
  home.shell.enableBashIntegration = true;

  # ========================================
  # 🧰 Пользовательские пакеты
  # Установка программ в профиль пользователя
  # ========================================
  home.packages = with pkgs; [
    # Основные утилиты
    vim
    wget
    curl
    git
    yt-dlp
    bottom  # btop в профиле

    # Редакторы
    kdePackages.kate
    kdePackages.breeze
    nodejs
    mpvScripts.webtorrent-mpv-hook
  ];

  # ========================================
  # 🌍 GIT: настройки пользователя
  # ========================================
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Новый правильный формат для имени и почты:
    settings = {
      user = {
        name = "SafeOwn";
        email = "safe@safeown.ru";
      };
    };

    ignores = [
      ".DS_Store"
      "__pycache__"
      "*.pyc"
      ".cache"
      ".idea"
    ];
  };

  # ========================================
  # 🔄 ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ
  # ========================================
  home.sessionVariables = {
    PATH = "$HOME/bin:$HOME/.npm-global/bin:$PATH";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    # Увеличение масштаба в Electron
    CHROME_DEVICE_SCALE_FACTOR = "2";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    DXVK_HDR = "1";
    ENABLE_HDR_WSI = "1";
  };

  # ========================================
  # 🔄 Webtorrent node для mpv
  # ========================================

  # 🎬 Установка webtorrent-mpv-hook без использования ломающегося npm
  home.activation.install-webtorrent-mpv-hook = lib.mkOrder 1000 ''
    echo "📦 Синхронизация webtorrent-mpv-hook..."
    mkdir -p ~/.config/mpv/scripts
    rm -f ~/.config/mpv/scripts/webtorrent.js

    # Берем готовый JS-файл напрямую из пакета NixOS
    TARGET_JS="${pkgs.mpvScripts.webtorrent-mpv-hook}/share/mpv/scripts/webtorrent.js"

    if [ -f "$TARGET_JS" ]; then
      ln -sf "$TARGET_JS" ~/.config/mpv/scripts/webtorrent.js
      echo "✅ Плагин успешно привязан!"
    else
      echo "❌ Ошибка: плагин не найден в хранилище Nix."
    fi
  '';


#   home.file.".npm-global/.keep".text = "";
#
#   home.activation.install-webtorrent-mpv-hook = lib.mkOrder 1000 ''
#     echo "📦 Установка или обновление webtorrent-mpv-hook..."
#
#     # Добавляем node в PATH для дочерних процессов npm
#     export PATH="${pkgs.nodejs}/bin:$PATH"
#
#     mkdir -p ~/.npm-global
#     # Устанавливаем пакет, если его нет
#     if ! command -v webtorrent-mpv-hook &> /dev/null; then
#       ${pkgs.nodejs}/bin/npm install -g webtorrent-mpv-hook --prefix ~/.npm-global
#     fi
#
#     # Создаём директорию для скриптов mpv
#     mkdir -p ~/.config/mpv/scripts
#
#     # Пересоздаём симлинк — на случай, если путь изменился
#     rm -f ~/.config/mpv/scripts/webtorrent.js
#
#     # Определяем, где лежит скрипт — build/ или dist/
#     SCRIPT_PATH=""
#     if [ -f ~/.npm-global/lib/node_modules/webtorrent-mpv-hook/dist/webtorrent.js ]; then
#       SCRIPT_PATH=~/.npm-global/lib/node_modules/webtorrent-mpv-hook/dist/webtorrent.js
#     elif [ -f ~/.npm-global/lib/node_modules/webtorrent-mpv-hook/build/webtorrent.js ]; then
#       SCRIPT_PATH=~/.npm-global/lib/node_modules/webtorrent-mpv-hook/build/webtorrent.js
#     else
#       echo "❌ Не найден webtorrent.js ни в dist/, ни в build/!"
#       exit 1
#     fi
#
#     ln -sf "$SCRIPT_PATH" ~/.config/mpv/scripts/webtorrent.js
#     echo "✅ Симлинк создан: ~/.config/mpv/scripts/webtorrent.js -> $SCRIPT_PATH"
#   '';
#
#   home.file.".config/mpv/script-opts/webtorrent.conf".text = ''
#     node_path=${pkgs.nodejs}/bin/node
#     path=./
#     maxConns=100
#     port=8888
#     utp=yes
#     dht=yes
#     lsd=yes
#     downloadLimit=-1
#     uploadLimit=-1
#   '';

  # ========================================
  # 🖼️ KDE / PLASMA: интеграция и внешний вид
  # ========================================
  xdg.enable = true;

  # ========================================
  # 📁 XDG User Directories
  # Управление стандартными папками
  # ========================================

  xdg.userDirs.enable = true;
  xdg.userDirs.desktop = "$HOME/Рабочий стол";
  xdg.userDirs.documents = "$HOME/Документы";
  xdg.userDirs.download = "$HOME/Загрузки";
  xdg.userDirs.music = "$HOME/Музыка";
  xdg.userDirs.pictures = "$HOME/Изображения";
  xdg.userDirs.videos = "$HOME/Видео";
  xdg.userDirs.templates = "$HOME/Шаблоны";
  xdg.userDirs.publicShare = "$HOME/Общедоступные";


  # ========================================
  # 📁 Ярлык для браузера Brave и Chromium без запроса в начале пароль KDE Wallet
  # ========================================
  xdg.desktopEntries = {
    # 1. Исправленный ярлык для Brave
    "brave-browser" = {
      name = "Brave Web Browser";
      genericName = "Web Browser";
      exec = "brave --password-store=basic --disable-features=DbusSecretPortal --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
      icon = "brave-browser";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
    };

    # 2. Исправленный ярлык для Chromium
    "chromium-browser" = {
      name = "Chromium Web Browser";
      genericName = "Web Browser";
      exec = "chromium --password-store=basic --disable-features=DbusSecretPortal --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
      icon = "chromium-browser";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
    };
  };




  # ========================================
  # 📁 Принудительная синхронизация .config (декларативно, как в Nix)
  # ========================================
#   home.activation.copyConfig = lib.mkOrder 500 ''
#     echo "🔁 Принудительно применяем ~/.config из шаблона..."
#
#     mkdir -p "$HOME/.config"
#
#     # Копируем всё рекурсивно, с перезаписью, без подтверждений
#     cp -rLf "${./home/.config}/." "$HOME/.config/" 2>/dev/null || true
#
#     # Фиксим права на всякий случай
#     chown -R "$(whoami)" "$HOME/.config" 2>/dev/null || true
#     chmod -R u+rw "$HOME/.config" 2>/dev/null || true
#
#     echo "✅ ~/.config успешно синхронизирован"
#   '';

    # Второй метот копирования после загрузки kde
#   home.file.".config/autostart/copy-config.desktop".text = ''
#     [Desktop Entry]
#     Name=Copy config
#     Exec=sh -c 'cp -rLf "${./home/.config}/." "$HOME/.config/" 2>/dev/null; chmod -R u+rw "$HOME/.config"'
#     Type=Application
#     NoDisplay=true
#   '';


  # ========================================
  # 📁 Обои
  # ========================================

  #home.file."Изображения/wallpaper.jpg".source = ./wallpaper.jpg;

  # ========================================
  # 🔒 KScreenLocker — экран блокировки
  # ========================================
  # Ввод пароля сразу после выхода замените весь блок
  #[Daemon]
  #RequirePassword=false
  #Timeout=1
#   home.file.".config/kscreenlockerrc".text = ''
#     [ConfigurableLockScreen]
#     timeoutAction=0
#
#     [Daemon]
#     Autolock=false
#     LockGraceTime=0
#     RequirePassword=false
#     Timeout=0
#
#     [Greeter]
#     AutoLoginAgain=false
#
#     [Greeter][Wallpaper][org.kde.image][General]
#     Image=file://${lockscreen-wallpaper}
#     PreviewImage=file://${lockscreen-wallpaper}
#
#     [Module-General]
#     wallpaperPlugin=org.kde.image
#
#     [org.kde.image]
#     Image=file://${lockscreen-wallpaper}
#   '';

  # ========================================
  # 📁 Ярлыки
  # ========================================

  home.file."Рабочий стол/kate-root.desktop".text = ''
    [Desktop Entry]
    Name=Kate (Root)
    Comment=Редактировать файлы от root
    Exec=sudo -E kate %u
    Icon=kate
    Terminal=false
    Type=Application
    Categories=TextEditor;System;
    StartupNotify=true
    MimeType=text/plain;
  '';
  home.file."Рабочий стол/kate-root.desktop".executable = false;



  # ========================================
  # 🎮 Запуск x11 игр на wayland (game-run)
  # ========================================
  home.file.".local/bin/game-run".text = ''
    #!/usr/bin/env sh
    exec env GDK_BACKEND=x11 SDL_VIDEODRIVER=x11 QT_QPA_PLATFORM=xcb steam-run "$@"
  '';
  home.file.".local/bin/game-run".executable = true;


  # ========================================
  # 🖱️ Явное включение курсора для Home Manager
  # (Обязательно, так как в stylix.nix отключен autoEnable)
  # ========================================
  home.pointerCursor.enable = true;


  # ========================================
  # 📦 Версия home-manager
  # ========================================
  home.stateVersion = "26.05";
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";


  # ========================================
  # 🔧 Включение home-manager
  # ========================================
  programs.home-manager.enable = true;
}
