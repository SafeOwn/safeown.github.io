{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.mako = {
    enable = true;
    settings = {

      border-radius = "10";
      border-size = "2";
      default-timeout = "5000";
      height = "110";
      width = "300";
      max-visible = "5";
      layer = "overlay";
    };
  };
}
