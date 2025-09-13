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
    ./home/mpv.nix
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
  ];

  # ========================================
  # 🌍 GIT: настройки пользователя
  # ========================================
  programs.git = {
    enable = true;
    userName = "SafeOwn";
    userEmail = "safe@safeown.ru";
    lfs.enable = true;
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
    PATH = "$HOME/bin:$PATH";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    # Увеличение масштаба в Electron
    CHROME_DEVICE_SCALE_FACTOR = "2";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    DXVK_HDR = "1";
    ENABLE_HDR_WSI = "1";
  };

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
  # 📁 Копирование всей папки .config как шаблона
  # ========================================
  home.activation.copyConfig = lib.mkAfter ''
    echo "🔁 Удаляем старую папку ~/.config..."
    rm -rf "$HOME/.config"

    echo "📁 Создаём новую папку ~/.config..."
    mkdir -p "$HOME/.config"

    echo "🔁 Копируем папку .config как обычные файлы (без симлинков)..."
    cp -Lr "${./home/.config}"/* "$HOME/.config/" 2>/dev/null || true

    echo "🔐 Устанавливаем права владельца..."
    chown -R "$(whoami)" "$HOME/.config"
    chmod -R u+rw "$HOME/.config"

    echo "✅ Папка ~/.config успешно скопирована и готова к использованию"
  '';


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
  # 📦 Версия home-manager
  # ========================================
  home.stateVersion = "25.11";

  # ========================================
  # 🔧 Включение home-manager
  # ========================================
  programs.home-manager.enable = true;
}
