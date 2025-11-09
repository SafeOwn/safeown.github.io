{ config, pkgs, lib, ... }: {

  # 1. Устанавливаем клиент
  environment.systemPackages = with pkgs; [
    rustdesk
  ];

  # 2. Включаем pipewire — ОБЯЗАТЕЛЬНО для захвата экрана в Wayland
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;  # если нужен звук
  };

  # 3. Используем xdg.portal с kdePackages (для Qt6/KDE6)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # 4. Устанавливаем переменные окружения для сессии
  services.xserver.displayManager.sessionCommands = ''
    export XDG_CURRENT_DESKTOP=KDE
    export XDG_SESSION_TYPE=wayland
  '';

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "KDE";
    XDG_SESSION_TYPE = "wayland";
    # Важно: добавляем пути к порталам в XDG_DATA_DIRS
    XDG_DATA_DIRS = [
      "${pkgs.kdePackages.xdg-desktop-portal-kde}/share"
      "/run/current-system/sw/share"
    ];
  };

  # 5. (Опционально) Сервер RustDesk — закомментирован, как у вас
  # services.rustdesk-server = {
  #   enable = true;
  #   openFirewall = true;
  #   signal = {
  #     relayHosts = [ "127.0.0.1" ];
  #   };
  #   relay.enable = true;
  # };
}
