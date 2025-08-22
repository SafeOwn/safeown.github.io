{
  description = "NixOS configuration with Plasma, NVIDIA, and Yandex Browser";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, yandex-browser, ... }:
    let
      system = "x86_64-linux";

      # Разрешаем import из дериваций (нужно для path:)
      specialArgs = {
        allowImportFromDerivation = true;
        inherit yandex-browser;
      };

      mkSystem = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules;
        inherit specialArgs;
      };

      hardwareConfig = ./modules/hardware-configuration.nix;
    in
    {
      nixosConfigurations = {
        desktop = mkSystem [
          hardwareConfig
          ./modules/base.nix
        ];

        yandex = mkSystem [
          hardwareConfig
          ./modules/base.nix
          ./modules/yandex.nix
        ];
      };
    };
}
