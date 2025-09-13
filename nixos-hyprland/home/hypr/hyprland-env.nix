{
  config,
  pkgs,
  ...
}: {
  home = {
    sessionVariables = {
      GTK_THEME = "Gruvbox-Dark-BL-LB";
      GTK_CURSOR_THEME = "Simp1e-Dark";
      EDITOR = "hx";
      BROWSER = "firefox";
      TERMINAL = "wezterm";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      CLUTTER_BACKEND = "wayland";
      WLR_RENDERER = "vulkan";
      GDK_SCALE = 2;
      XCURSOR_SIZE = 24;

      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
