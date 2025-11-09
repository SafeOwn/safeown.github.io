{ config, pkgs, ... }:

let
  lampacDir = "/var/lib/lampac";
in
{
  # Разрешаем .NET 9
  nixpkgs.config.permittedInsecurePackages = [ "dotnet-runtime-9.0.9" ];

  # Создаём директорию /var/lib/lampac с правильными правами
  systemd.tmpfiles.rules = [
    "d ${lampacDir} 0755 safe safe - -"
  ];

  # Служба Lampac
  systemd.services.lampac = {
    description = "Lampac Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "safe";
      WorkingDirectory = lampacDir;
      ExecStart = "${pkgs.dotnet-aspnetcore_9}/bin/dotnet ${lampacDir}/Lampac.dll";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # Открываем порт в фаерволе
  networking.firewall.allowedTCPPorts = [ 9118 ];
}
