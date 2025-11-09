{ config, pkgs, ... }:

let
  ds4drvScript = builtins.path {
    path = ./start-ds4drv.sh;
    name = "start-ds4drv.sh";
  };

  gamepadInhibitorScript = builtins.path {
    path = ./gamepad-idle-inhibitor.py;
    name = "gamepad-idle-inhibitor.py";
  };

  # 🔑 ИСПРАВЛЕНИЕ: Python с зависимостями
  gamepadPython = pkgs.python3.withPackages (ps: with ps; [ evdev pyudev ]);

  gamepadInhibitorWrapper = pkgs.writeShellScriptBin "gamepad-idle-inhibitor" ''
    #!${pkgs.bash}/bin/bash
    export PATH="${gamepadPython}/bin:${pkgs.qt6.qttools}/bin:$PATH"
    exec ${gamepadPython}/bin/python3 ${gamepadInhibitorScript} "$@"
  '';
in
{
  systemd.services.ds4drv = {
    enable = true;
    description = "DS4DRV Bluetooth/Gamepad driver service";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScriptBin "ds4drv-runner" ''
        #!${pkgs.bash}/bin/bash
        export NIX_PATH=nixpkgs=${pkgs.path}
        export PATH=${pkgs.git}/bin:${pkgs.nix}/bin:${pkgs.python313}/bin:$PATH
        cd /tmp
        exec ${pkgs.bash}/bin/bash ${ds4drvScript} 2>&1 | tee -a /var/log/ds4drv.log
      ''}/bin/ds4drv-runner";

      Restart = "always";
      RestartSec = "5";
      StandardOutput = "journal";
      StandardError = "journal";
      User = "root";
    };
  };

  users.users.safe.extraGroups = [ "input" ];

  systemd.user.services.gamepad-idle-inhibitor = {
    enable = true;
    description = "Gamepad Idle Inhibitor for KDE";
    # 🔑 КЛЮЧЕВОЕ ИЗМЕНЕНИЕ:
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    script = "${gamepadInhibitorWrapper}/bin/gamepad-idle-inhibitor";

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
