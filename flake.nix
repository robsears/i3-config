{
  description = "i3 window manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    inputs@{ self, nixpkgs }:
    let
      # Since this is just configuration files, we don't need per-system outputs
      # We'll use a dummy system just to get access to pkgs
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # plumb in various packages from platform and other inputs via overlays
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

    };
}
