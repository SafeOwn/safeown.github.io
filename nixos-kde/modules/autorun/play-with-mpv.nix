{ config, pkgs, ... }:

let
  # Получаем исходный код play-with-mpv
  playWithMpvSrc = pkgs.fetchFromGitHub {
    owner = "alesar1";
    repo = "play-with-mpv";
    rev = "035f98fbb74b38649ff9ed7e30ecba31d3fc16db";
    sha256 = "coCwwcSoZkuBvMpZxufTu4iTsJdj7ZLDyUrC0GMzG6w=";
  };

  # Создаём изолированное Python-окружение БЕЗ tkinter
  # (tkinter НЕ входит в python311.withPackages по умолчанию!)
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    flask
    pyperclip
    yt-dlp  # или youtube-dl, если предпочитаешь
  ]);

  # Обёртка для запуска
  playWithMpv = pkgs.writeShellScriptBin "play-with-mpv" ''
    # Устанавливаем минимально необходимые переменные окружения
    export DISPLAY=:0
    export XDG_RUNTIME_DIR=/run/user/$(id -u safe)
    export HOME=/home/safe

    # Запускаем скрипт с правильным Python-окружением
    exec ${pythonEnv}/bin/python ${playWithMpvSrc}/play-with-mpv "$@"
  '';
in
{
  # Обязательно: включаем fallback, чтобы игнорировать недоступные кэши (вроде yazi.cachix.org)
  nix.settings = {
    fallback = true;
    # Если у тебя где-то прописан yazi.cachix — лучше удали его,
    # но fallback спасёт, если не удалишь.
  };

  # Устанавливаем наш play-with-mpv в систему
  environment.systemPackages = [ playWithMpv ];

  # Настройка пользователя (убедись, что он существует!)
  users.users.safe = {
    isNormalUser = true;
    home = "/home/safe";
    createHome = true;
    group = "users";
    extraGroups = [ "video" "audio" ]; # на всякий случай
  };

  # Systemd-сервис
  systemd.services.play-with-mpv = {
    description = "Play with MPV";
    after = [ "graphical-session.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "safe";
      Group = "users";
      ExecStart = "env ENABLE_HDR_WSI=1 ${playWithMpv}/bin/play-with-mpv";
      Restart = "on-failure";
      RestartSec = "5s";
      # Environment не задаём — всё в скрипте
    };
  };

  # Остальная конфигурация системы
  services.xserver.enable = true;  # или false, если headless — но тогда DISPLAY не нужен
  # ... остальное ...
}
