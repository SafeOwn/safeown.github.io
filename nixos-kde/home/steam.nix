# /etc/nixos/modules/gaming.nix
{ config, pkgs, lib, ... }:

{
  # Разрешаем unfree: Steam и GE-Proton
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
    "proton-ge-bin"
  ];

  # Включаем Steam с нужными опциями
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;

    # Добавляем GE-Proton из Nixpkgs
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Улучшаем совместимость: добавляем библиотеки для Gamescope и некоторых игр
  programs.steam.package = pkgs.steam.override {
    extraPkgs = pkgs': with pkgs'; [
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib  # libstdc++.so.6
      libkrb5
      keyutils
    ];
  };

  # Включаем GameMode для оптимизации производительности
  programs.gamemode.enable = true;

  # Устанавливаем MangoHud (для отладки и FPS-счётчика)
  environment.systemPackages = with pkgs; [
    mangohud
  ];

  # Поддержка Vulkan (важно для AMD/NVIDIA)
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Для AMD: принудительно используем RADV (лучшая производительность)
  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
  };

  # Поддержка Steam Controller / Valve Index
  hardware.steam-hardware.enable = true;

  # Опционально: Gamescope как основная среда (как на Steam Deck)
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Если хочешь запускать Steam напрямую через Gamescope (без рабочего стола)
  # services.greetd.enable = true;
  # services.getty.autologinUser = "ваш_пользователь";
  # services.greetd.settings.default_session = {
  #   command = "${pkgs.gamescope}/bin/gamescope -W 1920 -H 1080 -f -e -- steam -gamepadui";
  #   user = "ваш_пользователь";
  # };

  # Утилиты для других лаунчеров (Lutris, Heroic и т.д.)
  environment.systemPackages = with pkgs; environment.systemPackages ++ [
    lutris
    heroic
    protonup-qt  # GUI для установки других версий Proton
    steam-run    # Для запуска .sh/.bin игр
  ];

  # Включаем Flatpak, если хочешь использовать Steam из Flathub
  services.flatpak.enable = true;
  xdg.portal.enable = true;
}
