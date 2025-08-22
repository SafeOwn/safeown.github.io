# /etc/nixos/hardware-configuration.nix
# ⚠️ Не редактируй вручную! Сгенерировано nixos-generate-config
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # --- Ядро: модули для initrd (обязательно здесь) ---
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # --- Файловые системы (обязательно здесь) ---
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f8ec6eb3-f6a6-44d8-91c8-a8abdaf6a397";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5871-3CBA";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ {
    device = "/dev/disk/by-uuid/91358c34-5df0-4fa7-af73-a6ac6e5880ef";
  } ];

  # --- Сеть и архитектура ---
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
