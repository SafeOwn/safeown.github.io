# /etc/nixos/modules/autorun/ciadpi.nix
{ config, pkgs, ... }:

let
  # 👇 Читаем бинарник как Nix-путь (доступен только внутри flake!)
  ciadpiBinary = builtins.path {
    path = ./ciadpi;  # относительно этого файла
    name = "ciadpi";  # имя в /nix/store (не обязательно)
  };
in
{
  systemd.services.ciadpi = {
    enable = true;
    description = "ciadpi traffic obfuscation service";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScriptBin "ciadpi" ''
        #!${pkgs.bash}/bin/bash
        exec ${ciadpiBinary} -Ku -a3 -An -Kt,h -n vk.com -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -Mh,d -As -Kt,h -n vk.com -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -S -Mh,d
      ''}/bin/ciadpi";

      Restart = "always";
      RestartSec = "5";
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
