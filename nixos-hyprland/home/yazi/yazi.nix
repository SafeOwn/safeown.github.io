{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./keymap.nix
    ./plugins.nix
    # ./theme-yazi.nix
  ];
  programs.yazi = {
    enable = true;
    package = inputs.yazi.packages.${pkgs.system}.default;
    enableBashIntegration = true;
    initLua = ./init.lua;

    theme = import ./theme-yazi.nix {
      inherit
        lib
        config
        ;
    };
    settings = {

      plugin = {
        prepend_previewers = [
          {
            mime = "application/bittorrent";
            # name = ".torrent";
            run = "piper -- transmission-show \"$1\"";
          }
          {
            name = "*/";
            run = "piper -- eza -TL=3 --color=always --icons=always --group-directories-first --no-quotes \"$1\"";
          }
          {
            name = "*/";
            run = "folder";
            sync = true;
          }
          {
            name = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
          {
            name = "/run/media/USER_NAME/**/*";
            run = "noop";
          }
        ];
        append_previewers = [
          {
            name = "*";
            run = "piper -- hexyl --border=none --terminal-width=$w \"$1\"";
          }
        ];
        prepend_preloaders = [
          {
            name = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
          {
            name = "/run/media/safe/**/*";
            run = "noop";
          }
        ];
      };
      log.enable = true;
      mgr = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "alphabetical";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
        mouse_events = [
          "click"
          "scroll"
          "touch"
          "move"
          "drag"
        ];
      };
      preview = {
        wrap = "yes";
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
        cache_dir = "";
        ueberzug_scale = 1;
        ueberzug_offset = [
          0
          0
          0
          0
        ];
      };
    };
  };
}
