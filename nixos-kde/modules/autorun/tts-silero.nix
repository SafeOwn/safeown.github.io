# ========================================
# 📄 /etc/nixos/modules/autorun/tts-silero.nix
# Автозагрузка Silero TTS V5 сервера
# Запускается как user service от пользователя safe
# ========================================
{ pkgs, lib, ... }:

{
  # Системный systemd сервис (запускается от root, но работает от safe)
  systemd.services.silero-tts = {
    description = "Silero TTS V5 Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "safe";
      Group = "users";
      WorkingDirectory = "/home/safe";
      Environment = "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib";
      ExecStart = "/home/safe/silero-tts-env-311/bin/python /home/safe/silero-v5-server.py";
      Restart = "always";
      RestartSec = 10;

      # Безопасность (минимальная, чтобы не ломало)
      NoNewPrivileges = true;
    };
  };

  # Firewall: разрешаем порт 8002 локально
  networking.firewall.allowedTCPPorts = [ 8002 ];
}
