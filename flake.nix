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
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            {
              pkgs = import nixpkgs {
                inherit system;
              };
              inherit system self;
              arch = builtins.elemAt (builtins.split "-" system) 0;
            }
            // inputs
          )
        );
    in
    {
      # Define packages for all supported systems
      packages = forAllSystems (args: import ./nix/packages.nix args);

      # Expose this flake as a NixOS module to easily integrate with NixOS and Home Manager
      nixosModules.default =
        { config, pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            self.packages.${pkgs.system}.default # scripts need to be in PATH and executable
            speedtest-cli # needed by internet-speeds script
            # TODO: what other dependencies are needed?
          ];

          # put i3 config in the right place for NixOS with home-manager
          home-manager.sharedModules = [
            {
              xdg.configFile."i3".source = "${self.packages.${pkgs.system}.default}";
            }
          ];
        };
    };
}
