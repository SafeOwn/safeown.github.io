{
  lib,
  pkgs,
  config,
  ...
}:
{

  stylix = {
    enable = true;
    autoEnable = false;

    targets = {
      # sway.enable = true;
      hyprland.enable = true;
      hyprland.hyprpaper.enable = false;
      hyprpaper.enable = false;
      hyprlock.enable = true;
      hyprlock.useWallpaper = false;
      gtk.enable = true;
      # qt.enable = true;
      ghostty.enable = true;
      foot.enable = true;
      zathura.enable = true;
      # kitty.enable = true;
      mako.enable = true;
      # micro.enable = true;
      mpv.enable = true;
      wofi.enable = true;
      rio.enable = true;
      fzf.enable = true;
      # alacritty.enable = true;
      bemenu = {
        enable = false;
        fontSize = 20;
      };
      btop.enable = true;
      yazi.enable = true;
      helix.enable = false;
      wezterm.enable = true;
      waybar = {
        enable = true;
        enableCenterBackColors = true;
        enableLeftBackColors = true;
        enableRightBackColors = true;
        # background = lib.mkDefault "@base00";
        addCss = false;
        #  customStyle = /etc/nixos/waybar/theme.css;
      };
      firefox = {
        enable = true;
        # colorTheme.enable = true;
        profileNames = [ "safe" ];
      };
      xresources.enable = true;
    };
  };
}
