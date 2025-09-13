{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
{
  imports = [
    ./home/hypr/hyprland.nix
    ./home/hypr/hyprcursor.nix
    ./home/hypr/hypridle.nix
    ./home/hypr/hyprlock.nix
    ./home/hypr/hyprpaper.nix
    # ./home/hypr/hyprpolkitagent.nix
    # ./home/hypr/hyprsunset.nix
    ./home/firefox.nix
    ./home/fastfetch.nix
    ./home/fzf.nix
    ./home/eza.nix
    ./home/zoxide.nix
    ./home/stylix_home.nix
    ./home/waybar/waybar.nix
    ./home/yazi/yazi.nix
    ./home/helix/helix.nix
    ./home/zathura.nix
    ./home/xdg.nix
    ./home/mako.nix
    ./home/ghostty.nix
    # ./home/foot.nix
    # ./home/rio.nix
    # ./home/zellij.nix
    ./home/wezterm.nix
    ./home/gtk.nix
    ./home/btop.nix
    ./home/imv.nix
    ./home/mpv.nix
    ./home/bash/bash.nix
    ./home/wofi/wofi.nix
    # ./home/bemenu.nix
    ./home/gpg.nix
    ./home/udiskie.nix
    ./home/golang.nix
    ./home/clipse.nix
    # ./home/sway.nix
  ];
  # TODO please change the username & home directory to your own
  home.username = "safe";
  home.homeDirectory = "/home/safe";
  home.shell.enableBashIntegration = true;
  #  home-manager.users.safe = [{
  #  stylix.targets.xyz.enable = false;
  #}];

  #  home.pointerCursor = {
  #    package = pkgs.simp1e-cursors;
  #    gtk.enable = true;
  #    name = "Simp1e-Gruvbox-Dark";
  #    size = 24;
  #  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  # home.packages = with pkgs; [
  # here is some command line tools I use frequently
  # feel free to add your own or remove some of them
  # terminal file manager
  # ];

  # basic configuration of git, please change to your own
  #  programs.git = {
  #    enable = true;
  #    userName = "safe";
  #    userEmail = "";
  #  };

  # starship - an customizable prompt for any shell
  #  programs.starship = {
  #    enable = true;
  #    # custom settings
  #    settings = {
  #      add_newline = false;
  #      aws.disabled = true;
  #      gcloud.disabled = true;
  #      line_break.disabled = true;
  #    };
  #  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
  };
}
