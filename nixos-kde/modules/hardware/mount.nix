{ config, pkgs, lib, ... }:


{
  # ==============================================================
  # 🖥️ ЗАГРУЗЧИК (UEFI)
  # ==============================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Количество отображения всего nixos rebuild сборок в boot
  boot.loader.timeout = 5;  # Выбор начального времини ОС и nixos rebuild

  boot.plymouth.enable = true; # Включить Plymouth (графический экран загрузки)
  boot.plymouth.theme = "hud_3";  # ← имя темы

  # Устанавливаем только тему hud3 из коллекции adi1090x
  boot.plymouth.themePackages = with pkgs; [
    (adi1090x-plymouth-themes.override {
      selected_themes = [ "hud_3" ];
    })
  ];

  # Основной раздел Win10 NTFS
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/CAB2E03CB2E02E9F";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "ro"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел Game NTFS там же где Linux
  fileSystems."/mnt/game" = {
    device = "/dev/disk/by-uuid/01DC10CC866597D0";  # ← Замени на UUID из blkid
    fsType = "ntfs-3g";         # или "ntfs-3g"
    options = [
      "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
      "nosuid"
      "uid=1000"            # твой пользователь (safe → id 1000)
      "gid=100"             # группа users
      "dmask=022"
      "fmask=133"
      "windows_names"       # запрещает имена, которые сломают Windows
      "nofail"              # ← если не смонтировался — не падать
    ];
  };

  # Раздел SDD NTFS
#   fileSystems."/mnt/sdd" = {
#     device = "/dev/disk/by-uuid/766666326665F2F3";  # ← Замени на UUID из blkid
#     fsType = "ntfs-3g";         # или "ntfs-3g"
#     options = [
#       "rw"                  # чтение и запись (если чтение и запись rw, но нужно отключить FastBoot Windows)
#       "nosuid"
#       "uid=1000"            # твой пользователь (safe → id 1000)
#       "gid=100"             # группа users
#       "dmask=022"
#       "fmask=133"
#       "windows_names"       # запрещает имена, которые сломают Windows
#       "nofail"              # ← если не смонтировался — не падать
#     ];
#   };







   # ✅ Разрешить пользователю safe монтировать без пароля
   security.polkit.enable = true;
   security.polkit.extraConfig = ''
     polkit.addRule(function(action, subject) {
       if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
            action.id == "org.freedesktop.udisks2.filesystem-mount") &&
           subject.user == "safe") {
         return polkit.Result.YES;
       }
     });
   '';


#    # ✅ Раздел Archive NTFS — монтируется при первом обращении
#   fileSystems."/mnt/archive" = {
#     device = "/dev/disk/by-uuid/635E73EE8E38A8CF";
#     fsType = "ntfs-3g";
#     options = [
#       "rw"
#       "nosuid"
#       "uid=1000"
#       "gid=100"
#       "dmask=022"
#       "fmask=133"
#       "windows_names"
#       "nofail"
#     ];
#   };
#
#   # ✅ Раздел Program NTFS
#   fileSystems."/mnt/program" = {
#     device = "/dev/disk/by-uuid/49090D06A3D0E968";
#     fsType = "ntfs-3g";
#     options = [
#       "rw"
#       "nosuid"
#       "uid=1000"
#       "gid=100"
#       "dmask=022"
#       "fmask=133"
#       "windows_names"
#       "nofail"
#     ];
#   };
#
#   # ✅ Раздел Disel NTFS
#   fileSystems."/mnt/disel" = {
#     device = "/dev/disk/by-uuid/E281603962F2F129";
#     fsType = "ntfs-3g";
#     options = [
#       "rw"
#       "nosuid"
#       "uid=1000"
#       "gid=100"
#       "dmask=022"
#       "fmask=133"
#       "windows_names"
#       "nofail"
#     ];
#   };

   # ✅ Сервис: переводим /dev/sdb в standby при загрузке через 20 мин. ВНИМНИЕ!!! Большой износ, при перезагрузке и rebuild включается hdd
   # ✅ Сервис: переводим HDD в standby при загрузке через 20 мин. по стабильному ID
   systemd.services.hdd-standby-at-boot = {
     description = "Put HDD Seagate into standby at boot";
     wantedBy = [ "multi-user.target" ];
     after = [ "local-fs.target" ];
     serviceConfig = {
       Type = "oneshot";
       ExecStart = "${pkgs.hdparm}/bin/hdparm -S 240 /dev/disk/by-id/ata-ST31500341AS_9VS4TBHW";
       RemainAfterExit = true;
     };
   };

   # ✅ Установка hdparm для управления питанием диска sdb.  ВНИМНИЕ!!! Большой износ, при перезагрузке и rebuild включается hdd
   environment.systemPackages = with pkgs; [ hdparm ];

   # ✅ Настройка udev: при монтировании раздела — ставим таймер сна диска (20 минут)
   # ✅ Настройка udev: привязываемся к серийному номеру железки, чтобы диск не раскручивался при ребилде
   services.udev.extraRules = ''
     SUBSYSTEM=="block", ATTRS{serial}=="9VS4TBHW", ENV{DEVTYPE}=="disk", RUN+="${pkgs.hdparm}/bin/hdparm -S 240 /dev/%k"
   '';


}
