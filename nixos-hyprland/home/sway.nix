{
  pkgs,
  ...
}:
{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    extraSessionCommands = ''export WLR_RENDERER=vulkan'';
    systemd = {
      enable = true;
      # extraCommands = [ "sleep 5; systemctl --user start kanshi.service" ];
    };
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "ghostty";
      startup = [
        # Launch Firefox on start
        { command = "ghostty"; }
      ];
    };
  };
}
