{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.stable; [
    # gcc
    #    wezterm
    # zathura
    duckstation
  ];
}
