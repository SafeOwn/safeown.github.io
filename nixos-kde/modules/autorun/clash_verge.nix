{ config, pkgs, ... }:

{

  # --- Clash Verge ---
  systemd.user.services.clash-verge-gui = {
    description = "Clash Verge GUI on login (minimized to tray)";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.clash-verge-rev}/bin/clash-verge";
      Environment = [
      "QT_QPA_PLATFORM=xcb"
      "XDG_CURRENT_DESKTOP=KDE"
      ];
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # --- Запускать оба при входе ---
  systemd.user.targets.graphical-session.wants = [
    "clash-verge-gui.service"
  ];
}
