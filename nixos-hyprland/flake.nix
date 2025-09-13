{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs.url = "nixpkgs/master";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # hyprland.url = "github:hyprwm/Hyprland";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#    disko = {
#      url = "github:nix-community/disko";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-unstable,
      # hyprland,
      yazi,
      chaotic,
      ghostty,
      #disko,
      stylix,
      home-manager,
      wezterm,

    }:
    let
      version = "25.05";

      system = "x86_64-linux";

      overlay-stable = final: prev: {
        stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {

      nixosConfigurations = {
        pc = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                nixpkgs.overlays = [
                  overlay-stable
                  overlay-unstable
                ];
                environment.systemPackages = [
                  # yazi.packages.${pkgs.system}.default
                  # ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
                  # ghostty.packages.${pkgs.system}.default
                  # wezterm.packages.${pkgs.system}.default
                ];
              }
            )

            ./configuration.nix
            chaotic.nixosModules.default
            # disko.nixosModules.disko
            #./disk-config.nix
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # TODO replace ryan with your own username
              home-manager.users.safe = import ./home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            }
          ];
        };
      };
    };
}
