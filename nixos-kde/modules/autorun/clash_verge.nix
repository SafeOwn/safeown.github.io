{ config, pkgs, ... }:

{
  systemd.user.services.clash-verge-gui = {
    description = "Clash Verge GUI";

    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      ExecStart = "${pkgs.clash-verge-rev}/bin/clash-verge";

      # ГЛАВНОЕ: отключаем DMA-BUF и композитинг WebKit для NVIDIA
      Environment = [
        "WEBKIT_DISABLE_DMABUF_RENDERER=0"
        "WEBKIT_DISABLE_COMPOSITING_MODE=1"
      ];

      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
