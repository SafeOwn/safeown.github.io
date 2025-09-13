{ config, pkgs, lib, ... }:  # ← ДОБАВЛЕНО pkgs, lib — теперь smbclient будет найден

{
  # ========================================
  # 🖥️ SMB / Samba — клиент и сервер
  # Просмотр сетевых папок + расшаривание своих
  # ========================================

  # === Клиентские пакеты для работы с SMB ===
  environment.systemPackages = with pkgs; [
    samba                       # CLI-клиент: smbclient -L //server
    cifs-utils                  # Для монтирования через mount -t cifs
    #kdePackages.kio-extras      # Интеграция SMB в Dolphin (KDE)
    nbtscan                     # Сканирование NetBIOS-имён в сети
  ];


  # ========================================
  # 🌐 Сетевое обнаружение (Avahi + WSDD)
  # Чтобы компьютеры видели друг друга в сети
  # ========================================

  # === Avahi (mDNS) — для обнаружения .local устройств ===
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # Поддержка имён вида hostname.local
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  # === WS-Discovery — совместимость с Windows 10/11 ===
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;  # ← Открываем порты автоматически
  };

  security.wrappers."mount.cifs" = {
    program = "mount.cifs";
    source = "${pkgs.cifs-utils}/bin/mount.cifs";
    owner = "root";
    group = "root";
    setuid = true;
    };


  # ========================================
  # 🔥 Брандмауэр и разрешение имён
  # Открываем порты и настраиваем DNS/mDNS
  # ========================================

  # === Открываем порты SMB в фаерволе ===
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  # === Чтобы имена .local разрешались корректно ===
  environment.etc."nsswitch.conf".text = ''
    passwd: files systemd
    group: files systemd
    hosts: files mdns_minimal [NOTFOUND=return] dns
    services: files
  '';


  # ========================================
  # 🔐 GVFS альтернативный бэкенд монтирования
  # ========================================

  # === GVFS — альтернативный способ монтирования (через gio) ===
  services.gvfs.enable = true;


  # ========================================
  # 📁 Samba-сервер — расшариваем разделы в сеть
  # Другие компьютеры смогут к ним подключаться
  # ========================================

  services.samba = {
    enable = true;
    # УДАЛЕНО: securityType — устарело в 25.05
    # ВСЁ перенесено в settings.global

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS Samba Server";
        "security" = "user";        # ← ЗАМЕНА securityType
        "map to guest" = "Bad User";
      };

      # Домашняя папка
      "home" = {
        "path" = "/home/safe";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      # Общая папка
      "public" = {
        "path" = "/mnt/shared";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      # === NTFS-разделы — расшариваем все ===

      "windows" = {
        "path" = "/mnt/windows";
        "browseable" = "yes";
        "read only" = "yes";     # Только чтение (смонтирован ro)
        "guest ok" = "yes";      # Доступ без пароля
        "create mask" = "0444";
        "directory mask" = "0555";
      };

      "game" = {
        "path" = "/mnt/game";
        "browseable" = "yes";
        "read only" = "no";      # Можно писать
        "guest ok" = "no";       # Требует аутентификации
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      "sdd" = {
        "path" = "/mnt/sdd";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      "archive" = {
        "path" = "/mnt/archive";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      "program" = {
        "path" = "/mnt/program";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      "disel" = {
        "path" = "/mnt/disel";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };


  # ========================================
  # ⚙️ Активация: автоматическое добавление пользователя Samba
  # Выполняется при nixos-rebuild switch
  # ========================================

#   system.activationScripts.addSambaUser = {
#     text = ''
#       # Проверяем, существует ли пользователь safe в системе
#       if id "safe" &>/dev/null; then
#         # Проверяем, есть ли уже пользователь в Samba
#         if ! sudo -u safe smbpasswd -e safe &>/dev/null; then
#           echo "Добавляем пользователя 'safe' в Samba..."
#           ${pkgs.samba}/bin/smbpasswd -a safe || true
#         else
#           echo "Пользователь 'safe' уже существует в Samba."
#         fi
#       else
#         echo "Пользователь 'safe' не существует в системе — пропускаем добавление в Samba."
#       fi
#     '';
#     deps = [ "users" ];  # Запускать после создания пользователей
#   };

  # ========================================
  # ⚙️ Напоминания
  # ========================================

  system.activationScripts.remindSambaPassword = {
    text = ''
        if ! smbpasswd -e safe &>/dev/null; then
        echo ""
        echo "⚠️  ВАЖНО: Не забудьте создать пароль Samba: sudo smbpasswd -a safe"
        echo ""
        fi
    '';
    deps = [ "users" ];
    };
}
