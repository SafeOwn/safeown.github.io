{ config, pkgs, lib, ... }:

let
  # Создаём обёртку, которая эмулирует твой ручной скрипт
  ds4drvScript = pkgs.writeShellScriptBin "ds4drv-wrapper" ''
    #!${pkgs.bash}/bin/bash

    # Пути к зависимостям
    EVDEV_PATH="${pkgs.python313Packages.evdev}/${pkgs.python313.sitePackages}"
    PYUDEV_PATH="${pkgs.python313Packages.pyudev}/${pkgs.python313.sitePackages}"

    # Клонируем и патчим ds4drv (как в твоём скрипте)
    cd /tmp
    rm -rf ds4drv
    ${pkgs.git}/bin/git clone https://github.com/chrippa/ds4drv.git
    cd ds4drv

    sed -i 's/device\.fn/device.path/g' ds4drv/actions/input.py
    sed -i 's/SafeConfigParser/ConfigParser/g' ds4drv/config.py

    # Устанавливаем PYTHONPATH как в твоём скрипте
    export PYTHONPATH="$(pwd):$EVDEV_PATH:$PYUDEV_PATH"

    # Запускаем
    exec ${pkgs.python313}/bin/python3 -m ds4drv --hidraw
  '';
in
{
  environment.systemPackages = [ ds4drvScript ];

  boot.kernelModules = [ "uinput" ];
  boot.blacklistedKernelModules = [ "hid_playstation" ];

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", SYMLINK+="ds4"
  '';

  users.users.root.extraGroups = [ "input" ];

  systemd.services.ds4drv = {
    enable = true;
    description = "DualShock 4 to Xbox 360 Controller Emulator";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${ds4drvScript}/bin/ds4drv-wrapper";
      Restart = "on-failure";
      RestartSec = "5s";

      DeviceAllow = [
        "/dev/hidraw* rw"
        "/dev/input/event* rw"
        "/dev/uinput rw"
        "/dev/ds4 rw"
      ];

      AmbientCapabilities = "CAP_SYS_ADMIN";
      CapabilityBoundingSet = "CAP_SYS_ADMIN";

      User = "root";

      # Разрешаем запись в /tmp
      ReadWritePaths = [ "/tmp" ];
    };
  };
}
