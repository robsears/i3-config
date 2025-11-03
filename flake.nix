{
  description = "i3 window manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    inputs@{ self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      overlays = import ./nix/overlays.nix inputs;
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            {
              pkgs = import nixpkgs {
                inherit system overlays;
              };
              inherit system self;
              arch = builtins.elemAt (builtins.split "-" system) 0;
            }
            // inputs
          )
        );
    in
    {
      packages = forAllSystems (args: import ./nix/packages.nix args);

      nixosModules.default =
        { config, pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            self.packages.${pkgs.system}.default
            speedtest-cli
          ];
          home-manager.sharedModules = [
            {
              xdg.configFile."i3".source = "${self.packages.${pkgs.system}.default}";
            }
          ];
        };
    };
}
