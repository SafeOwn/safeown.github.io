{
  config,
  lib,
  pkgs,
  ...
}:
{
  gtk = {
    enable = true;

    #  cursorTheme = {
    #    #package = pkgs.simp1e-cursors;
    #    name = "Simp1e-Gruvbox-Dark";
    #    size = 24;
    #  };

    # iconTheme = {
    #package = pkgs.gruvbox-plus-icons;
    #name = "Papirus-Dark";
    # name = "Gruvbox-Plus-Dark";
    # };

    #  theme = {
    #    package = pkgs.gruvbox-gtk-theme;
    #    name = "Gruvbox-Dark";
    #  };

    #	font = {
    #	package = pkgs.nerdfonts;
    #	name = "JetBrainsMono Nerd Font Regular";
    #	size = 11;
    #	};

    # gtk3.extraConfig = {
    #   Settings = ''
    #     gtk-application-prefer-dark-theme=1
    #   '';
    # };

    # gtk4.extraConfig = {
    #   Settings = ''
    #     gtk-application-prefer-dark-theme=1
    #   '';
    # };
  };
  # home.sessionVariables.GTK_THEME = "Gruvbox-Dark";
}
