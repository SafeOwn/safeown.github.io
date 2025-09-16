{ config, pkgs, ... }:

{
  systemd.user.services.openrgb-gui = {
    description = "OpenRGB GUI with 'safe' profile and minimized start";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${config.services.hardware.openrgb.package}/bin/openrgb --profile \"safe\" --startminimized";
      Environment = [ "QT_QPA_PLATFORM=xcb" ];
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  systemd.user.targets.graphical-session.wants = [ "openrgb-gui.service" ];
}
