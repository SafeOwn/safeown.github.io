{ config, pkgs, ... }:

{
  systemd.user.services.openrgb-gui = {
    description = "OpenRGB GUI with 'safe' profile and minimized start";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --profile \"safe\" --startminimized";
      Environment = [ "QT_QPA_PLATFORM=wayland;xcb" ];
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # ВАЖНО: Закомментируйте эту строку, она может вызывать дублирование
  # systemd.user.targets.graphical-session.wants = [ "openrgb-gui.service" ];
}
