# ========================================
# 📦 Flatpak — поддержка сторонних приложений
# Безопасная настройка с автоматическим добавлением Flathub
# ========================================

{ pkgs, lib, ... }:

{
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "KDE";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";  # Для Electron-приложений на Wayland
  };

  # ✅ Безопасный способ: systemd-сервис уровня пользователя
  # Запускается один раз при первом входе safe
  systemd.user.services.flatpak-flathub-setup = {
    description = "Добавить Flathub remote в Flatpak (однократно)";
    wantedBy = [ "default.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        flatpak = "${pkgs.flatpak}/bin/flatpak";
      in pkgs.writeShellScript "flathub-setup" ''
        if ! ${flatpak} --user remote-list 2>/dev/null | grep -q flathub; then
          echo "📦 Добавляем Flathub..."
          ${flatpak} --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
          echo "✅ Flathub добавлен."
        else
          echo "ℹ️ Flathub уже настроен."
        fi
      '';
      # Используем %h — домашняя директория пользователя в systemd
      ConditionPathExists = "!%h/.config/.flathub-setup-done";
    };
    postStart = "${pkgs.coreutils}/bin/touch %h/.config/.flathub-setup-done";
  };

  # Политики для установки Flatpak-приложений без пароля
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user !== "safe") return;

      if (action.id === "org.freedesktop.Flatpak.app-install" ||
          action.id === "org.freedesktop.Flatpak.app-uninstall") {
        return polkit.Result.YES;
      }
    });
  '';
}
