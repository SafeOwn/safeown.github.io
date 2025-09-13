# ========================================
# 🔊 /etc/nixos/audi-bluetooth.nix
# Настройка аудио (PipeWire) и Bluetooth
# Управляет:
# - Включением Bluetooth
# - Настройкой PipeWire вместо PulseAudio
# - Поддержкой ALSA, 32-битных приложений, Pulse-совместимости
# Работает с любыми материнскими платами, включая MSI
# ========================================
{ pkgs, lib, ... }:  # Добавлен `lib` — нужен для mkForce

{
  # Устанавливаем UCM-профили для Realtek (важно для 5.1)
  environment.systemPackages = with pkgs; [
    alsa-utils
    alsa-ucm-conf
    pulseaudioFull  # ← для pactl, pavucontrol, ucm-профилей
  ];

  hardware = {
    # ========================================
    # 📶 Bluetooth
    # Включает Bluetooth и расширенные функции
    # ========================================
    bluetooth = {
      enable = true;                    # ✅ Включить Bluetooth
      powerOnBoot = true;               # ✅ Включать при загрузке
      settings.General = {
        Experimental = true;            # ✅ Включить экспериментальные функции (LE Audio и др.)
        # ControllerMode = "bredr";     # ⚠️ Только Classic Bluetooth (не нужно)
      };
    };
  };

  services = {
    # ========================================
    # 🎧 Аудио: PipeWire вместо PulseAudio
    # Современная аудио-подсистема с низкой задержкой
    # ========================================
    pulseaudio.enable = lib.mkForce false;  # ✅ Принудительно отключаем сервис PulseAudio (чтобы не конфликтовал с PipeWire)

    pipewire = {
      enable = true;                   # ✅ Включить PipeWire
      audio.enable = true;             # ✅ Включить аудио
      wireplumber.enable = true;       # ✅ Управление устройствами (аналог pulseaudio-module-device-restore)
      alsa.enable = true;              # ✅ Поддержка ALSA (все старые приложения)
      alsa.support32Bit = true;        # ✅ Поддержка 32-битных приложений (Wine, старые игры)
      pulse.enable = true;             # ✅ Совместимость с PulseAudio (приложения работают без изменений)

      # jack.enable = true;            # ⚠️ Раскомментировать, если нужны JACK-приложения (DAW, Ardour)
    };
  };


    # Принудительно загрузить UCM для MSI
    boot.extraModprobeConfig = ''
      options snd-hda-intel model=msi-headset-multi
    '';
}
