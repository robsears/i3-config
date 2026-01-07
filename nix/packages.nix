{ pkgs, ... }:
let
  default = pkgs.stdenvNoCC.mkDerivation {
    pname = "i3-config";
    version = "1.0.0";

    src = ./.;

    # No build phase needed for configuration files
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/data
      mkdir -p $out/scripts

      cp    ${../config} $out/config
      cp -r ${../scripts}/* $out/scripts/

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Personal i3 window manager configuration";
      platforms = platforms.all;
    };
  };
in
{
  inherit default;
}
