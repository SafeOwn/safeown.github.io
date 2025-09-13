# ========================================
# 🦊 /etc/nixos/home/firefox.nix
# Настройка браузера Firefox
# Управляет:
# - Профилями
# - Настройками (включая GPU, кэш, приватность)
# - Языковыми пакетами
# - Политиками (ограничения, путь загрузок)
# Работает с KDE, GNOME, Hyprland и др.
# ========================================
{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;  # ✅ Включить Firefox в системе

    # ========================================
    # 🧑 Профили пользователей
    # Можно создать несколько профилей (например, work, personal)
    # ========================================
    profiles = {
      "safe" = {
        id = 0;                    # Идентификатор профиля
        isDefault = true;          # Делать профилем по умолчанию

        # ========================================
        # ⚙️ Настройки Firefox (prefs.js)
        # Прямое управление параметрами через about:config
        # ========================================
        settings = {
          "general.useragent.locale" = "ru";
          "intl.locale.requested" = "ru-RU";



          # 🖼️ Включить аппаратное ускорение (WebRender)

          "gfx.webrender.all" = true; # для включения расскоментируйте опцию и убрать gfx.canvas, media.hardware-video-decoding
#           "gfx.webrender.all" = false;  # Использует GPU для рендеринга страниц (текст, CSS, анимации)
#           "gfx.canvas.azure.backends" = "software";  # использовать software rendering для canvas | Ускоряет 2D/3D графику
#           "media.hardware-video-decoding.enabled" = false;  # Использует GPU для декодирования видео (H.264, VP9, AV1)



          "browser.cache.disk.enable" = false;   # 🔽 Отключить кэширование на диске (экономит SSD, ускоряет работу)
          "widget.gtk.global-menu.wayland.enabled" = true;  # 🌐 Включить глобальное меню в KDE (Wayland)
          "media.av1.enabled" = true; # AV1-декодирование
        };

        # ========================================
        # 🧩 Расширения
        # Управление установкой расширений
        # force = false → Nix не будет перезаписывать расширения, установленные вручную
        # ========================================
        extensions = {
          force = false;  # ✅ Позволяет устанавливать расширения вручную (через интерфейс)
        };
      };
    };

    # ========================================
    # 🌍 Языковые пакеты
    # Установка поддержки русского и английского языков
    # ========================================
    languagePacks = [
      "en-US"
      "ru"
    ];

    # ========================================
    # 🛡️ Политики (управление через enterprise policies)
    # Аналог group policy в Windows
    # ========================================
    policies = {
      # 📥 Куда сохранять файлы по умолчанию
      DefaultDownloadDirectory = "\${home}/Downloads";

      # 🚫 Отключить телеметрию и сбор данных
      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      # 🚫 Не проверять, установлен ли Firefox браузером по умолчанию
      DontCheckDefaultBrowser = true;

      # 🚫 Отключить Pocket (встроенную закладку)
      DisablePocket = true;
    };
  };
}
