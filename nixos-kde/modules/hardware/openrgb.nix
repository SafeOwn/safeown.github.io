{ config, pkgs, ... }:

{

  # --- ОБЯЗАТЕЛЬНО: I2C и ядро ---
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  hardware.i2c.enable = true;

   environment.systemPackages = with pkgs; [
    i2c-tools
  ];


  # --- ВКЛЮЧАЕМ OpenRGB и ЗАМЕНЯЕМ ПАКЕТ НА 1.0rc1 ---
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.package = pkgs.openrgb.overrideAttrs (old: {
    src = pkgs.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "release_candidate_1.0rc1";
      sha256 = "sha256-jKAKdja2Q8FldgnRqOdFSnr1XHCC8eC6WeIUv83e7x4=";
    };

    postPatch = ''
      patchShebangs scripts/build-udev-rules.sh
      substituteInPlace scripts/build-udev-rules.sh \
        --replace-fail /usr/bin/env "${pkgs.coreutils}/bin/env"
    '';
  });

  # --- ДОПОЛНИТЕЛЬНЫЕ ЗАВИСИМОСТИ ДЛЯ СТАБИЛЬНОСТИ (как в примере) ---
  systemd.services.openrgb.after = [ "network.target" ];
  systemd.services.openrgb.wants = [ "dev-usb.device" ];
}
