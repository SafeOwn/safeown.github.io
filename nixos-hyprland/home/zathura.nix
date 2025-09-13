{ pkgs, ... }:
{
  programs.zathura = {
    enable = true;
    # package = pkgs.stable.zathura;
    #    extraConfig = ''
    #      database = "sqlite";
    #    '';
  };
}
