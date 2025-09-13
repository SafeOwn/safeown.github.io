{ lib, config, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        no_fade_in = true;
        no_fade_out = true;
      };

      animations = {
        enable = false;
      };

      # background = [
      # {
      # monitor = "";
      #  path = "/home/safe/Pictures/Wallpapers/fol.jpg";
      # color = lib.mkForce "rgb(${config.stylix.base16Scheme.base00})";

      #  all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
      # blur_passes = 0;
      # blur_size = 0;
      # noise = 0.0;
      # contrast = 0.0;
      # brightness = 0.0;
      # vibrancy = 0.0;
      # vibrancy_darkness = 0.0;
      # }
      # ];

      # input-field = [
      #  {
      # monitor = "";
      # size = "200, 50";
      # outline_thickness = 1;
      # dots_size = 0.2;
      # dots_spacing = 0.15;
      # dots_center = true;
      #  outer_color = "rgb(000000)";
      # inner_color = "rgb(200, 200, 200)";
      # font_color = "rgb(10, 10, 10)";
      # fade_on_empty = true;
      #  placeholder_text = '\'Password...'\';
      # hide_input = false;
      # position = "0, -20";
      # halign = "center";
      # valign = "center";
      #   }
      #   ];

      # label = [
      #  {
      # monitor = "";
      #   text = "Enter your password to unlock";
      # color = "rgba(200, 200, 200, 1.0)";
      # font_size = 25;
      # font_family = "Noto Sans";

      #  position = "0, 200";
      # halign = "center";
      # valign = "center";
      #  }
      #  ];
    };
  };
}
