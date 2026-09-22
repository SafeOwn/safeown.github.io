{ pkgs, lib, config, ... }:

let
  # ── Python с пакетами ───────────────────────────────────────────────────
  # torch CPU-версия — этого хватает для Silero (инференс на CPU быстрее GPU
  # для мелких моделей из-за накладных расходов на копирование)
  pythonWithDeps = pkgs.python313.withPackages (ps: with ps; [
    torch
    torchaudio
    fastapi
    uvicorn
    numpy
  ]);

  # ── Скрипт сервера в Nix Store ──────────────────────────────────────────
  serverScript = pkgs.writeTextFile {
    name = "silero-tts-server";
    executable = true;
    destination = "/bin/silero-tts-server.py";
    text = builtins.readFile ../../scripts/SileroTTS/server.py;
    checkPhase = ''
      ${pythonWithDeps}/bin/python3 -m py_compile $out/bin/silero-tts-server.py
    '';
  };

  # ── Команда для ручного запуска ─────────────────────────────────────────
  silero-tts = pkgs.writeShellApplication {
    name = "silero-tts";
    runtimeInputs = [ pythonWithDeps ];
    text = ''
      exec ${pythonWithDeps}/bin/python3 ${serverScript}/bin/silero-tts-server.py
    '';
  };
in
{
  # ── Systemd служба (системная, с автозагрузкой) ─────────────────────────
  # lib.mkForce перебивает определения из старого модуля tts-silero.nix,
  # если он всё ещё где-то в imports. Так конфликта не будет.
  systemd.services.silero-tts = {
    description = lib.mkForce "Silero TTS V5.5 Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];   # ← АВТОЗАГРУЗКА

    serviceConfig = lib.mkForce {
      Type = "simple";
      User = "safe";
      Group = "users";
      WorkingDirectory = "/home/safe";

      ExecStart = "${pythonWithDeps}/bin/python3 ${serverScript}/bin/silero-tts-server.py";

      Restart = "always";
      RestartSec = 10;

      NoNewPrivileges = true;
      PrivateTmp = true;

      # Логи в journald (по умолчанию) — можно смотреть journalctl
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # ── Пакеты в систему ────────────────────────────────────────────────────
  environment.systemPackages = [
    pythonWithDeps
    silero-tts
  ];

  # ── Порты для фаервола (если включён) ───────────────────────────────────
  # Слушаем только 127.0.0.1, но на всякий случай
  networking.firewall.allowedTCPPorts = lib.mkIf config.networking.firewall.enable [ ];
}
