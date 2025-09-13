# ========================================
# ⌨️ /etc/nixos/modules/hardware/keyboard-touchpad.nix
# Настройка клавиатуры, тачпада и управления питанием
# Управляет:
# - Поведением при закрытии крышки
# - Долгим нажатием кнопки питания
# - Естественной прокруткой на тачпаде
# Работает в KDE, Hyprland, Sway и др.
# ========================================
{ pkgs, ... }:

{
  # ========================================
  # 🚀 БЫСТРОЕ ВЫКЛЮЧЕНИЕ И ПЕРЕЗАГРУЗКА
  # ========================================
  # 1. Уменьшаем таймауты глобально — чтобы система не ждала 90 сек
  systemd.settings.Manager.DefaultTimeoutStopSec = "5s";

  # 2. Автоматически убиваем процессы пользователя при выключении
  services.logind.settings.Login = {
    KillUserProcesses = true;
    KillOnlyUsers = [ "safe" ];
  };

  # 3. Уменьшаем таймауты для проблемных сервисов — чтобы не тормозили выключение
  systemd.user.services.gamemoded.serviceConfig.TimeoutStopSec = "3s";
  systemd.user.services.pipewire.serviceConfig.TimeoutStopSec = "3s";
  systemd.user.services.wireplumber.serviceConfig.TimeoutStopSec = "3s";
  systemd.user.services.gvfs-daemon.serviceConfig.TimeoutStopSec = "3s";

  # 4. Аварийная перезагрузка, если система зависла при выключении
  systemd.services.emergency-reboot-on-shutdown-hang = {
    description = "Emergency reboot if shutdown hangs for more than 10 seconds";
    wantedBy = [ "final.target" ];
    before = [ "systemd-reboot.service" ];
    script = ''
      # Запускаем таймер в фоне
      (
        sleep 10
        echo "EMERGENCY: Shutdown is hanging - forcing reboot..." > /dev/kmsg
        systemctl --force reboot
      ) &
      # Главный процесс ждёт завершения системы
      while systemctl is-system-running | grep -q "stopping\|degraded"; do
        sleep 1
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutSec = "15s";
    };
  };

  # 5. (Опционально) Отключи Baloo, если не нужен
  # services.kde.baloo.enable = false;

  # 6. (Опционально) Отключи gamemoded, если не играешь
  # services.gamemode.enable = false;


  # ========================================
  # 🛌 УПРАВЛЕНИЕ СНОМ: ОЧИСТКА ПЕРЕД СНОМ
  # ========================================
  # Останавливаем звук, Plasma и прочее перед сном — чтобы не зависло при пробуждении
  systemd.services.pre-suspend-cleanup = {
    description = "Stop user services before suspend";
    script = ''
      # Останавливаем звук
      systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null || true

      # Останавливаем Plasma (если Wayland)
      systemctl --user stop plasma-plasmashell plasma-kwin_wayland 2>/dev/null || true

      # Убиваем всё, что может зависнуть
      pkill -f "plasmashell\|kwin\|pipewire" 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "sleep.target" ];  # Запускается ПЕРЕД сном
  };


  # ========================================
  # 🌅 ВОССТАНОВЛЕНИЕ ПОСЛЕ СНА
  # ========================================
  systemd.services.post-resume-restore = {
    description = "Restore user services after resume";
    script = ''
      sleep 3
      loginctl unlock-sessions 2>/dev/null || true
      systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || \
      systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "suspend.target" ];
  };


  # ========================================
  # 🖥️ ПРОБУЖДЕНИЕ ГРАФИКИ: ФИКС ЧЁРНОГО ЭКРАНА
  # ========================================
  # Принудительно переключаем TTY, чтобы "разбудить" графический стек NVIDIA + Wayland
  # Трюк: TTY1 → TTY2 → возвращает фокус и перезапускает рендеринг
  systemd.services.post-resume-delay = {
    description = "Force graphics stack wake-up after resume";
    script = ''
      sleep 5

      # 🔁 Переключаемся на TTY1 (текстовую консоль)
      ${pkgs.utillinux}/bin/chvt 1
      sleep 2

      # 🔁 Переключаемся обратно на TTY2 (графическую сессию)
      ${pkgs.utillinux}/bin/chvt 2
      sleep 3

      # Разблокируем сессии
      loginctl unlock-sessions 2>/dev/null || true

      # 💥 Гарантированно перезапускаем Plasma и KWin — даже если они "живы", но сломаны
      systemctl --user restart plasma-plasmashell plasma-kwin_wayland 2>/dev/null || \
      systemctl --user start plasma-plasmashell plasma-kwin_wayland 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Добавляем PATH, чтобы loginctl и systemctl работали корректно
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.utillinux}/bin:${pkgs.systemd}/bin";
    };
    wantedBy = [ "suspend.target" ];
  };


  # ========================================
  # 🔌 УПРАВЛЕНИЕ ПИТАНИЕМ (logind)
  # Настройка поведения при действиях с питанием
  # ========================================
  services.logind.settings.Login = {
    # 🖥️ Закрытие крышки ноутбука → приостановка
    HandleLidSwitch = "suspend";

    # ⏻ Кнопка питания → приостановка
    HandlePowerKey = "suspend";

    # ⏻ Долгое нажатие кнопки питания → выключение
    HandlePowerKeyLongPress = "poweroff";
  };


  # ========================================
  # ✋ ТАЧПАД (через libinput)
  # Настройка поведения тачпада
  # ========================================
  services.libinput.touchpad = {
    # ✅ Естественная прокрутка (как на Mac/смартфонах)
    naturalScrolling = true;

    # ⚙️ Другие настройки можно раскомментировать при необходимости:
    # accelProfile = "flat";     # Ускорение курсора
    # tapping = true;            # Тап для клика
    # clickMethod = "clickfinger"; # Одно/двух/трёхпальцевые клики
  };
}
