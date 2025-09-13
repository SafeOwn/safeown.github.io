{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      disable_prime = false;
      width = "25%";
      height = "50%";
      prompt = "Search...";
      normal_window = true;
      location = "center";
      # gtk-dark = true;
      allow_images = false;
      image_size = 32;
      insensitive = true;
      allow_markup = true;
      no_actions = true;
      orientation = "vertical";
      hide_scroll = true;
      # halign = "fill";
      # content_halign = "fill";

    };
    style = lib.mkForce ''
      ${builtins.readFile ./style.css}
    '';

  };
}
