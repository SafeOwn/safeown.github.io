{ pkgs, ... }:

{
  # --- ОБЯЗАТЕЛЬНО: Модули ядра для шины подсветки ---
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    i2c-tools
  ];

  # --- ВКЛЮЧАЕМ НАДЁЖНЫЙ И СТАБИЛЬНЫЙ СИСТЕМНЫЙ СЕРВИС OPENRGB ---
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb; # ИСПОЛЬЗУЕМ СТАНДАРТНЫЙ ПАКЕТ 1.0rc2 БЕЗ СЛОМАННЫХ ХЭШЕЙ
  };

  # --- Настройки стабильности сервиса ---
  systemd.services.openrgb.after = [ "network.target" ];
  systemd.services.openrgb.wants = [ "dev-usb.device" ];
}
