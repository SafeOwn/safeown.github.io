# ========================================
# 🎨 /etc/nixos/stylix.nix
# Универсальная темизация системы на основе base16
# Применяет цвета к GTK, терминалам, GRUB, tty, курсорам и т.д.
# Работает с KDE, Hyprland, GNOME и др.
# ========================================
{ lib, pkgs, config, ... }:

{
  stylix = {
    enable = true;             # ✅ Включить Stylix
    autoEnable = false;        # ❌ Не применять автоматически ко всем пакетам
    polarity = "dark";         # 🌑 Темная тема

    # 🔆 Фон: использовать цвет base00 как пиксель (для terminal/desktop)
#   image = config.lib.stylix.pixel "base00"; # base00 светлый экран
#     image = pkgs.runCommand "black-pixel.png" {
#       preferLocalBuild = true;
#       allowSubstitutes = false;
#     } "${pkgs.imagemagick}/bin/convert xc:#000000 -resize 1x1 png32:$out";
#     imageScalingMode = "fill"; # Растягивать фон

    # 🎨 Цветовая схема: Gruvbox Dark Hard
    base16Scheme = ./gruvbox-dark-hard-black.yaml;

#     # 🖱️ Курсор: Bibata
#      cursor = {
#       package = pkgs.bibata-cursors;
#       name = "Bibata-Modern-Classic";
#       size = 28;
#      };

    cursor = {
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 28;
    };


    # 🔳 Прозрачность
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 1.0;
    };

    # 🖋️ Шрифты
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      # Используем моноширинный шрифт везде
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;

      # 🎭 Emoji
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

        # 🔤 Размеры шрифтов 4k (3840x2160)
      sizes = {
        applications = 18;
        terminal = 20;
        desktop = 18;
        popups = 18;
      };

#       # 🔤 Размеры шрифтов FullHD (1920x1080)
#       sizes = {
#         applications = 13;
#         terminal = 15;
#         desktop = 13;
#         popups = 13;
#       };
    };

    # 🎯 Цели применения темы
    targets = {
      grub.enable = true;               # ✅ Цветной GRUB
      #gtk.enable = true;               # ✅ GTK-приложения (Firefox, Telegram)
      # qt.enable = true;              # ⚠️ Осторожно: может конфликтовать с KDE
      console.enable = true;           # ✅ Цвета в TTY (Ctrl+Alt+F1)
      nixos-icons.enable = true;       # ✅ Иконки в NixOS
      #chromium.enable = true;          # ✅ Тема для Chromium
    };
  };

  # ========================================
  # 🖱️ Курсор (через home-manager) — теперь отключён
  # Управление курсором передано Stylix
  # ========================================
  # home.pointerCursor = { ... };  # ❌ Закомментировано — теперь в stylix

  # ========================================
  # 📦 Установка тем и курсоров
  # ========================================
  environment.systemPackages = with pkgs; [
    # Иконки
    papirus-icon-theme
    # Тема Breeze (входит в KDE)
    kdePackages.breeze
    # Шрифты
    noto-fonts
    fira-code
  ];
}
