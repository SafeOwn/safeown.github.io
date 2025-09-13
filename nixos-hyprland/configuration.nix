# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  lib,
  stateVersion,
  ...
}:

let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  # session = "${pkgs.hyprland}/bin/Hyprland";
  session = "Hyprland";
  username = "safe";
in

{
  imports = [
    # Include the results of the hardware scan.
    ./boot-disk.nix
    ./cpu-gpu.nix
    ./keyboard-touchpad.nix
    ./audi-bluetooth.nix
    ./networks.nix
    ./overlay_unstable.nix
    ./overlay_stable.nix
    # ./tuigreet.nix
    ./stylix.nix
    ./xdg.nix
    #./disko-config.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services = {
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${session}";
          user = "${username}";
        };
        default_session = {
          command = "${tuigreet} --cmd ${session} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot' --theme 'border=blue;text=d5c4a1;prompt=green;time=red;action=d5c4a1;button=yellow;container=black;input=d5c4a1'";
          user = "greeter";
          # user = "${username}";
        };
      };
    };
    dbus.implementation = "broker";
    hypridle.enable = true;
    transmission = {
      enable = true;
      user = "safe";
      group = "users";
      home = "/home/safe";
      downloadDirPermissions = "775";
      settings = {
        incomplete-dir = "/home/safe/Torrent";
        download-dir = "/home/safe/Torrent";
      };
    };
    printing.enable = true;
  };

  #Fonts:
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "JetBrainsMono Nerd Font" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    # Enables compiling from source
    #nix.settings.substituters = lib.mkForce [ ];

    channel.enable = false;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
      # randomizedDelaySec = "30m";
    };

    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org/"
        "https://chaotic-nyx.cachix.org/"
        "https://yazi.cachix.org"
        "https://ghostty.cachix.org"
        "https://wezterm.cachix.org"
        # "https://wezterm-nightly.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        # "wezterm-nightly.cachix.org-1:zsTr51TeTCRg+bHwUr0KfW3XIIb7Avisrj/hXwVzC2c="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    #  registry = with lib.attrsets; let
    #    inputFlakes = filterAttrs (name: input: (input.flake or true)) inputs;
    #    configValue = mapAttrs (name: input: {flake = input;}) inputFlakes;
    #  in
    #    configValue;
    #  nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    # soteria.enable = true;
    #gnome.gnome-keyring.enable = true;
    #seahorse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.safe = {
    isNormalUser = true;
    #initialPassword = "";
    home = "/home/safe";
    description = "safe";
    extraGroups = [
      "video"
      "wheel"
      "transmission"
    ];
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs = {
  #   mtr.enable = true;
  #   iio-hyprland.enable = true;
  #   gnupg.agent = {
  #     enable = true;
  #     pinentryPackage = pkgs.pinentry-tty;
  #     enableSSHSupport = false;
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?


}
