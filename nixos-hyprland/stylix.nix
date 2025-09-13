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
    polarity = "dark";
    # image = /home/safe/Pictures/Wallpapers/fol1.jpg;
    image = config.lib.stylix.pixel "base00";
    imageScalingMode = "fill";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # base16Scheme = {

    #   base00 = "1d2021"; # ----
    #   base01 = "3c3836"; # ---
    #   base02 = "504945"; # --
    #   base03 = "665c54"; # -
    #   base04 = "bdae93"; # +
    #   base05 = "d5c4a1"; # ++
    #   base06 = "ebdbb2"; # +++
    #   base07 = "fbf1c7"; # ++++
    #   base08 = "fb4934"; # red
    #   base09 = "fe8019"; # orange
    #   base0A = "fabd2f"; # yellow
    #   base0B = "b8bb26"; # green
    #   base0C = "8ec07c"; # aqua/cyan
    #   base0D = "83a598"; # blue
    #   base0E = "d3869b"; # purple
    #   base0F = "d65d0e"; # brown

    # };
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Classic";
    cursor.size = 28;
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 1.0;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      # emoji = config.stylix.fonts.monospace;
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 13;
        terminal = 15;
        desktop = 13;
        popups = 13;
      };
    };
    targets = {
      grub.enable = true;
      gtk.enable = true;
      # qt.enable = true;
      console.enable = true;
      nixos-icons.enable = true;
      chromium.enable = true;

    };
  };
}
