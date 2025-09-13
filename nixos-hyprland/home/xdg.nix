{
  lib,
  config,
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;

    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        # xdg-desktop-portal-wlr
        # xdg-desktop-portal-termfilechooser
        # xdg-desktop-portal
      ];
      # config = {
      #   common.default = [ "hyprland" ];
      #   hyprland.default = [ "hyprland" ];
      #   hyprland."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ]; # xdg-?
      # };
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };
    mime.enable = true;
    # mimeApps.defaultApplications = {
    #   "application/x-gnome-saved-search" = [ "yazi.desktop" ];
    #   "application/x-directory" = [ "yazi.desktop" ];
    #   "inode/directory" = [ "yazi.desktop" ];
    #   "x-directory/normal" = [ "yazi.desktop" ];
    #   "x-scheme-handler/trash" = [ "yazi.desktop" ];
    # };
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    mimeApps = {
      associations.added = {
        "pdf" = "zathura.desktop";
      };
    };

    # xdg.configFile = {
    #   "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    #   "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    #   "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    #   "gtk-3.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-3.0/assets";
    #   "gtk-3.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-3.0/gtk.css";
    #   "gtk-3.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-3.0/gtk-dark.css";
    # };

    desktopEntries = {
      # helix = {
      #   name = "Helix";
      #   icon = "helix";
      #   comment = "Edit text files";
      #   exec = "ghostty -e hx";
      #   terminal = false;
      #   type = "Application";
      #   mimeType = [
      #     "text/english"
      #     "text/plain"
      #     "text/x-makefile"
      #     "text/x-c++hdr"
      #     "text/x-c++src"
      #     "text/x-chdr"
      #     "text/x-csrc"
      #     "text/x-java"
      #     "text/x-moc"
      #     "text/x-pascal"
      #     "text/x-tcl"
      #     "text/x-tex"
      #     "application/x-shellscript"
      #     "text/x-c"
      #     "text/x-c++"
      #   ];
      # };
      # yazi = {
      #   name = "Yazi";
      #   icon = "yazi";
      #   comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
      #   terminal = false;
      #   exec = "ghostty -e yazi";
      #   type = "Application";
      #   mimeType = [ "inode/directory" ];
      # };
      tjournal = {
        name = "Tjournal";
        icon = "gnote";
        comment = "tui bookmarks";
        terminal = false;
        # exec = "ghostty -e tjournal";
        type = "Application";
        mimeType = [ "text/plain" ];
      };
      chromium = {
        name = "Chromium_bybit";
        icon = "chromium";
        comment = "chromium brouser";
        terminal = false;
        exec = "chromium %U -silent-debugger-extension-api";
        type = "Application";
        mimeType = [
          "application/pdf"
          "application/rdf+xml"
          "application/rss+xml"
          "application/xhtml+xml"
          "application/xhtml_xml"
          "application/xml"
          "image/gif"
          "image/jpeg"
          "image/png"
          "image/webp"
          "text/html"
          "text/xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/webcal"
          "x-scheme-handler/mailto"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ];
      };
    };
  };
}
