{
  pkgs,
  inputs,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    # package = inputs.ghostty.packages.${pkgs.system}.default;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enableBashIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      quick-terminal-animation-duration = 0;
      custom-shader-animation = false;
      resize-overlay = "never";
      window-decoration = "none";
      window-theme = "system";
      window-padding-balance = true;
      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 0.01;
      selection-invert-fg-bg = true;
      cursor-invert-fg-bg = false;
      cursor-style = "block";
      cursor-style-blink = true;
      gtk-wide-tabs = true;
      gtk-titlebar = false;
      gtk-tabs-location = "bottom";
      gtk-single-instance = false;
      # gtk-adwaita = true;
      adw-toolbar-style = "flat";
      bold-is-bright = false;
      desktop-notifications = false;
      confirm-close-surface = false;
      clipboard-paste-protection = false;
      copy-on-select = false;
      window-save-state = "always";
      shell-integration-features = "no-cursor";
      auto-update = "off";
      gtk-opengl-debug = false;
      keybind = [
        "ctrl+n=new_window"
        "ctrl+h=goto_split:left"
        "ctrl+j=goto_split:bottom"
        "ctrl+k=goto_split:top"
        "ctrl+l=goto_split:right"
        "ctrl+a>h=new_split:left"
        "ctrl+a>j=new_split:down"
        "ctrl+a>k=new_split:up"
        "ctrl+a>l=new_split:right"
        "ctrl+a>f=toggle_split_zoom"
        "ctrl+a>n=next_tab"
        "ctrl+a>p=previous_tab"
      ];
    };
    # clearDefaultKeybinds = true;
  };
}
