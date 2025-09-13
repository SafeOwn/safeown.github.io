{
  lib,
  config,
  ...
}:
with config.lib.stylix.colors.withHashtag;
# let
#   fg = base06;
# in

# programs.yazi.theme = {
lib.mkForce {
  mgr = {
    cwd = {
      fg = base0B;
    };
    # Tab
    # tab_width = 10;
    # Border
    border_symbol = " ";
    # border_style = {
    # fg = base00;
    # fg = "#83A598";
    count_copied = {
      fg = base0B;
      bg = base00;
    };
    count_cut = {
      fg = base08;
      bg = base00;
    };
    count_selected = {
      fg = base0A;
      bg = base00;
    };
  };

  # Highlighting
  # syntect_theme = "";

  # Mode
  tabs = {
    active = {
      fg = base00;
      bg = base08;
      bold = true;
    };
    inactive = {
      fg = base05;
      bg = base00;
    };
    sep_inner = {
      open = "";
      close = "";
      # bg = base08;
    };
    sep_outer = {
      open = "";
      close = "";
    };
  };
  mode = {
    normal_main = {
      fg = base00;
      bg = base0D;
      bold = true;
    };
    normal_alt = {
      bg = base00;
      fg = base05;
    };
    select_main = {
      fg = base00;
      bg = base0B;
      bold = true;
    };
    select_alt = {
      bg = base00;
      fg = base05;
    };
    unset_main = {
      fg = base00;
      bg = base0F;
      bold = true;
    };
    unset_alt = {
      bg = base00;
      fg = base05;
    };
  };
  status = {
    sep_left = {
      open = "";
      close = "";
    };
    sep_right = {
      open = "";
      close = "";
    };
  };
  # status = {
  #   separator_open = "";
  #   separator_close = "";
  #   separator_style = {
  #     fg = "darkgray";
  #     bg = "darkgray";
  #   };

  # Permissions
  # permissions_t = {
  #   fg = "#A0CE48";
  # };
  # permissions_r = {
  #   fg = "#ECBA58";
  # };
  # permissions_w = {
  #   fg = "#D04638";
  # };
  # permissions_x = {
  #   fg = "#48AAD0";
  # };
  # permissions_s = {
  #   fg = "darkgray";
  # };
  # };
  # };
  # };

}
