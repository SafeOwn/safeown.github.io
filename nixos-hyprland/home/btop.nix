{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.btop = {
    enable = true;
    settings = {
      #  color_theme = "gruvbox_dark";
      theme_background = false;
      truecolor = true;
      vim_keys = true;
      show_battery = false;
      #presets = "proc:0:default";
    };
  };
}
