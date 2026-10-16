{
  description = "i3 window manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    inputs@{ self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
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
        { config, lib, options, pkgs, ... }:
        {
          # `options ? home-manager` has to be deferred inside `config` --
          # checking it at the top level of the module's returned attrset
          # (e.g. via `//`) forces `options` while NixOS is still building
          # `options` itself (it must call this module to classify its
          # shape), which is an infinite recursion.
          config = lib.mkMerge [
            {
              environment.systemPackages = with pkgs; [
                self.packages.${pkgs.stdenv.hostPlatform.system}.default # scripts need to be in PATH and executable
                i3 # i3 window manager, duh
                maim # screenshot tool
                terminator # terminal emulator
                feh # wallpaper setter
                imagemagick # needed by maim for image processing
                scrot # screenshot tool
              ];
            }
            (lib.optionalAttrs (options ? home-manager) {
              # put i3 config in the right place for NixOS with home-manager
              home-manager.sharedModules = [
                {
                  xdg.configFile."i3".source = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}";

                  # Create the data directory
                  home.activation.createI3DataDir = ''
                    if [ ! -d "$HOME/.config/i3-data" ]; then
                      mkdir -p "$HOME/.config/i3-data"
                      chmod 700 "$HOME/.config/i3-data"
                    fi
                  '';
                }
              ];
            })
          ];
        };
    };
}
