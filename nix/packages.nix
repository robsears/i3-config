{ pkgs, ... }:
let
  default = pkgs.runCommand "i3-config"
    {
      meta = with pkgs.lib; {
        description = "Personal i3 window manager configuration";
        platforms = platforms.linux;
      };
    }
    ''
      mkdir -p $out/scripts

      cp    ${../config} $out/config
      cp -r ${../scripts}/* $out/scripts/
    '';
in
{
  inherit default;
}
