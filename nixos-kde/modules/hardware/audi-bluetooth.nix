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

  # ========================================
  # 🐧 Ядро: Параметры загрузки для аудио
  # Отключаем SOF, включаем legacy HDA, убираем мешающие драйверы
  # ========================================
  boot.kernelParams = [
    "snd-intel-dspcfg.dsp_driver=1"    # ← Принудительно использовать legacy HDA, а не SOF
    "snd_hda_intel.dmic_detect=0"      # ← Отключить детект цифровых микрофонов (часто ломает Realtek)
    "modprobe.blacklist=snd_sof_pci_intel_tgl,snd_sof_intel_hda_common,snd_sof_intel_hda_generic,snd_sof"  # ← явно выключаем SOF
  ];


  # ========================================
  # 📁 Система: Обеспечиваем наличие UCM-профилей ALSA
  # Без них PipeWire не сможет правильно настроить 5.1 и форматы
  # ========================================
  environment.etc."alsa/ucm".source = "${pkgs.alsa-ucm-conf}/share/alsa/ucm";


  # ========================================
  # 📦 Пакеты: Утилиты для управления звуком
  # pactl, pavucontrol, профили Realtek — всё здесь
  # ========================================
  environment.systemPackages = with pkgs; [
    alsa-utils
    alsa-ucm-conf
    pulseaudioFull  # ← для pactl, pavucontrol, ucm-профилей
    pavucontrol

    pipewire
  ];


  # ========================================
  # 📶 Bluetooth: Включение и настройка
  # Поддержка LE Audio, включение при загрузке
  # ========================================
  hardware.bluetooth = {
    enable = true;                    # ✅ Включить Bluetooth
    powerOnBoot = true;               # ✅ Включать при загрузке
    settings.General = {
      Experimental = true;            # ✅ Включить экспериментальные функции (LE Audio и др.)
      # ControllerMode = "bredr";     # ⚠️ Только Classic Bluetooth (не нужно)
    };
  };


  # ========================================
  # 🎧 Аудио: Основной стек — PipeWire вместо PulseAudio
  # Современная система с низкой задержкой, поддержкой ALSA и 32-бит
  # ========================================
  services.pulseaudio.enable = lib.mkForce false;  # ✅ Принудительно отключаем PulseAudio

  services.pipewire = {
    enable = true;                   # ✅ Включить PipeWire
    audio.enable = true;             # ✅ Включить аудио
    wireplumber.enable = true;       # ✅ Управление устройствами (аналог device-restore)
    alsa.enable = true;              # ✅ Поддержка старых ALSA-приложений
    alsa.support32Bit = true;        # ✅ Поддержка 32-бит (Wine, старые игры)
    pulse.enable = true;             # ✅ Совместимость с PulseAudio-приложениями

    # jack.enable = true;            # ⚠️ Раскомментировать, если нужны JACK-приложения (DAW, Ardour)
  };


  # ========================================
  # 🎚️ PipeWire: Глобальные настройки (частота, буфер, качество ресэмплинга)
  # Через configPackages — единственный рабочий способ в NixOS 24.11+
  # ========================================
  services.pipewire.configPackages = [
    (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/99-audio-rate.conf" ''
      context.properties = {
        default.clock.rate = 48000
        default.clock.quantum = 2048
        default.clock.min-quantum = 1024
        default.clock.max-quantum = 8192
      }

      stream.properties = {
        resample.quality = 6
      }
    '')
  ];


  # ========================================
  # 🎛️ WirePlumber: Принудительная настройка USB-аудио (Realtek ALC4080)
  # Задаём 24-бит, 48 кГц, 6 каналов, буфер — как в Windows "Studio Quality"
  # ========================================
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/50-usb-audio-realtek.lua" ''
      rule = {
        matches = {
          {
            { "node.name", "matches", "alsa_output.usb-Generic_USB_Audio-00.*Speaker__sink" },
          },
        },
        apply_properties = {
          ["audio.rate"] = 48000,
          ["audio.format"] = "S24_3LE",     -- ← 24-бит, как в Windows (студийная запись)
          ["audio.channels"] = 6,
          ["clock.quantum"] = 2048,         -- ← буфер для этого устройства
          ["resample.quality"] = 6,
        },
      }

      table.insert(alsa_monitor.rules, rule)
    '')
  ];


  # ========================================
  # ⚙️ Ядро: Системные настройки для стабильности аудио
  # Больше памяти, больше времени для realtime-процессов
  # ========================================
  security.rtkit.enable = true;
  boot.kernel.sysctl = {
    "vm.min_free_kbytes" = 262144;       # ← больше свободной памяти для аудио
    "kernel.sched_rt_runtime_us" = 990000; # ← больше времени для realtime-аудио
  };


  # ========================================
  # 🚫 ALSA dmix: ОПЦИОНАЛЬНО (не включать!)
  # Оставлено для истории — в PipeWire не нужно, может сломать настройки
  # ========================================
  # environment.etc."asound.conf".text = ''
  #   pcm.!default {
  #     type plug
  #     slave.pcm "dmixer"
  #   }
  #
  #   pcm.dmixer {
  #     type dmix
  #     ipc_key 1024
  #     slave {
  #       pcm "hw:1,0"
  #       period_time 0
  #       period_size 2048
  #       buffer_size 65536
  #       rate 48000
  #       format S24_3LE
  #     }
  #     bindings {
  #       0 0
  #       1 1
  #       2 2
  #       3 3
  #       4 4
  #       5 5
  #     }
  #   }
  #
  #   ctl.!default {
  #     type hw
  #     card 1
  #   }
  # '';


  # ========================================
  # 🎚️ ALSA: Принудительная загрузка UCM-профиля для MSI
  # На всякий случай — auto обычно работает, но лучше явно
  # ========================================
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=auto
  '';

}
