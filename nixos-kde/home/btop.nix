{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.btop = {
  enable = true;  # ✅ Устанавливает и включает btop
  settings = {
    theme_background = false;  # ❌ Фон не затемнён (остаётся как в терминале)
    truecolor = true;          # ✅ Поддержка 24-битных цветов (красивее)
    vim_keys = true;           # ✅ Управление: h/j/k/l (как в vim)
    show_battery = false;      # ❌ Не показывать заряд батареи (для ПК)
    # color_theme = "gruvbox_dark";  # ⚠️ Закомментировано — тема по умолчанию
  };
};
}
