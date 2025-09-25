# ========================================
# 📄 /etc/nixos/flake.nix
# Главный файл конфигурации системы (Flake)
# Управляет:
# - Внешними источниками (каналы, пакеты)
# - Модулями NixOS
# - Пользовательскими окружениями (Home Manager)
# - Переходами между stable/unstable
#
# ВАЖНО: Этот файл активирует flakes и управляет всей системой.
# ========================================
{ description = "Конфигурация NixOS: KDE Plasma 6, sddm, nixpkgs stable/unstable";

  # ========================================
  # 🔗 Входные данные (inputs)
  # Внешние репозитории и каналы, используемые в системе
  # Каждый input — это отдельный источник пакетов или инструментов
  # ========================================
  inputs = {
    # 🔧 Основной канал Nixpkgs — нестабильный (для доступа к новым пакетам, например, Plasma 6)
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # 🧱 Стабильный канал NixOS 25.05
    # Используется для стабильных пакетов через pkgs.stable.firefox и т.д.
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    # 🔄 Дублирующий нестабильный канал (альтернативный источник)
    # Может использоваться для переключения или тестирования
#    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # 🎯 Chaotic-Nyx — сторонний репозиторий с патченными и новыми пакетами
    # Включает обновлённые версии ядер, KDE, драйверов и т.д.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
#    chaotic = {
#      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };

    # 🎨 Stylix — темизация системы на основе base16
    # Автоматически применяет цветовую схему к GTK, консолям, Wayland
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🏠 Home Manager — управление домашней директорией
    # Настройка .bashrc, .config, приложений, шрифтов, тем
     home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
     };
  };

  # ========================================
  # 🧩 Выходные данные (outputs)
  # Генерация конфигурации системы на основе inputs
  # ========================================
  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, chaotic, stylix, home-manager }:
    let
      # Версия системы (для совместимости)
      version = "25.05";

      # Архитектура системы
      system = "x86_64-linux";

       # ========================================
      # 🔧 Overlay: nixpkgs-stable
      # Позволяет использовать pkgs.stable.<package> в конфигурации
      # Пример: pkgs.stable.firefox
      # ========================================
      overlay-stable = final: prev: {
        stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;  # Разрешить проприетарные пакеты (NVIDIA, etc.)
        };
      };

      # ========================================
      # 🔧 Overlay: nixpkgs-unstable
      # Позволяет использовать pkgs.unstable.<package>
      # Пример: pkgs.unstable.plasma6
      # ========================================
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
      # ========================================
      # 🖥️ Конфигурация машины: pc
      # Определяет, как будет собрана система
      # Использует модули из других .nix файлов
      # ========================================
      nixosConfigurations.pc = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };  # Передаём inputs в модули

        # ========================================
        # 📦 Модули системы
        # Все .nix файлы, которые участвуют в сборке
        # ========================================
        modules = [
           (
              { config, pkgs, ... }:
              {
                  nixpkgs.config.allowUnfree = true;
                  nixpkgs.config.permittedInsecurePackages = [
                    "fex-2508.1"
                    "qtwebengine-5.15.19"
                  ];
                nixpkgs.config.allowUnsupportedSystem = true;
                nixpkgs.overlays = [
                  overlay-stable
                  overlay-unstable
                ];
                environment.systemPackages = [
                  # yazi.packages.${pkgs.system}.default
                  # ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
                  # ghostty.packages.${pkgs.system}.default
                  # wezterm.packages.${pkgs.system}.default
                ];
              }
            )

          # 🔧 Основная конфигурация системы
          ./configuration.nix

           # 💾 Автозагрузка
          ./modules/autorun/openrgb.nix           # Автозагрузка подсветки
          ./modules/autorun/cladpi/ciadpi.nix     # Автозагрузка обход интернета CiaDpi
          ./modules/autorun/clash_verge.nix       # Автозагрузка обход интернета Clash Vrge
          ./modules/autorun/ds4drv/ds4drv.nix     # Автозагрузка геймпада DualShok4 (определяется как xbox, нужен для LuxWine)

          # 💾 Аппаратные модули
          ./modules/boot-disk.nix            # Настройка загрузки (systemd-boot)
          ./modules/hardware/cpu-gpu.nix              # CPU, GPU, NVIDIA
          ./modules/hardware/keyboard-touchpad.nix    # Клавиатура и тачпад
          ./modules/hardware/audi-bluetooth.nix       # Аудио, Bluetooth, PipeWire
          ./modules/hardware/networks.nix             # Сеть, DNS, NetworkManager
          #./overlay_unstable.nix     # Подключение overlay unstable
          #./overlay_stable.nix       # Подключение overlay stable

          # 🎨 Темы и внешний вид
          #./xdg.nix                  # XDG Portals (для Wayland-совместимости)
          ./stylix.nix               # Тема Gruvbox через Stylix


		  stylix.nixosModules.stylix   # ← Это активирует модуль Stylix в NixOS

          # 🔐 Менеджер входа
          # ❌ УДАЛЁН: greetd
          # ✅ ИСПОЛЬЗУЕТСЯ: sddm (будет включен в configuration.nix)
          # chaotic.nixosModules.default  # Включает sddm и другие сервисы Chaotic-Nyx

          # 🏠 Home Manager — управление пользовательскими настройками
           home-manager.nixosModules.home-manager

          # 🧩 Дополнительный модуль: home-manager с передачей данных
          ({ config, lib, pkgs, ... }:
            let
              lockscreen-wallpaper = pkgs.runCommand "lockscreen-wallpaper" {} ''
                cp ${./home/wallpaper/lockscreen-wallpaper.jpg} $out
              '';
            in

            # 🧩 Дополнительные параметры Home Manager
            {
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;           # Использовать глобальные пакеты
              home-manager.useUserPackages = true;         # Добавлять пакеты из home.packages
              home-manager.extraSpecialArgs = { inherit inputs lockscreen-wallpaper; };  # Передаём inputs в home.nix
              home-manager.users.safe = import ./home.nix; # Конфиг пользователя safe

              # 🔧 Отключаем системный сервис HM — он не должен тормозить загрузку
              systemd.services."home-manager-safe".enable = lib.mkForce false;
            }
          )
        ];
      };
    };
}
