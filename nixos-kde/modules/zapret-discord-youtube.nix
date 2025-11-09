#1) ./general.bat                 4) ./general_alt3.bat           7) ./general_fake_tls_mod.bat  10) ./discord.bat
#2) ./general_alt.bat             5) ./general_alt4.bat           8) ./general_mgts.bat
#3) ./general_alt2.bat            6) ./general_alt5.bat           9) ./general_mgts2.bat

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.zapret-discord-youtube;
in {
  options.services.zapret-discord-youtube = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Zapret Discord YouTube Bypass";
    };

    strategy = mkOption {
      type = types.str;
      default = "general_alt2.bat";
    };

    interface = mkOption {
      type = types.str;
      default = "enp5s0";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ git nftables procps bash coreutils ];

    systemd.services.zapret-discord-youtube = {
      description = "Zapret Discord YouTube Bypass";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "forking";
        KillMode = "process-group";
        Restart = "always";
        RestartSec = 10;
        TimeoutStartSec = 30;
        TimeoutStopSec = 30;
        PermissionsStartOnly = true;

        ExecStop = "${pkgs.nftables}/bin/nft flush chain inet zapretunix output && ${pkgs.nftables}/bin/nft delete table inet zapretunix || true";
        ExecStopPost = "sh -c '${pkgs.procps}/bin/pkill -f nfqws' || true";
      };

      script = ''
        export PATH=${lib.makeBinPath [ pkgs.git pkgs.bash pkgs.coreutils ]}
        export TMPDIR=/run/user/0
        export BASE_DIR="/root/zapret-discord-youtube-linux/zapret-discord-youtube-linux"
        export interface="${cfg.interface}"
        export strategy="${cfg.strategy}"
        export NOINTERACTIVE="true"
        export auto_update="false"

        mkdir -p "$BASE_DIR" "$TMPDIR"
        cat > "$BASE_DIR/conf.env" <<EOF
        interface=$interface
        strategy=$strategy
        auto_update=false
        EOF

        cd "$BASE_DIR" || exit 1
        exec ${pkgs.bash}/bin/bash "$BASE_DIR/main_script.sh" -nointeractive
      '';

      wantedBy = [ "multi-user.target" ];
    };
  };
}
