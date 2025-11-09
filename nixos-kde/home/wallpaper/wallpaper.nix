{ lib, config, pkgs, lockscreen-wallpaper, ... }:

let
  # Путь к твоему обою (в Nix Store)
  wallpaper = pkgs.runCommand "wallpaper" {} ''
    cp ${./wallpaper.jpg} $out
  '';
in
{
  # ========================================
  # 🖼️ ОБОИ: Рабочий стол + Экран блокировки
  # Управляет обоими через один модуль
  # ========================================
  # Ввод пароля сразу после выхода замените весь блок
  #[Daemon]
  #RequirePassword=false
  #Timeout=1

  # 🔹 Обои на экране блокировки
  home.file.".config/kscreenlockerrc".text = ''
    [ConfigurableLockScreen]
    timeoutAction=0

    [Daemon]
    Autolock=false
    LockGraceTime=0
    RequirePassword=false
    Timeout=0

    [Greeter]
    AutoLoginAgain=false

    [Greeter][Wallpaper][org.kde.image][General]
    Image=file://${lockscreen-wallpaper}
    PreviewImage=file://${lockscreen-wallpaper}

    [Module-General]
    wallpaperPlugin=org.kde.image

    [org.kde.image]
    Image=file://${lockscreen-wallpaper}
  '';

}
