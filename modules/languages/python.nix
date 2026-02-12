{ config, pkgs, lib, userState, ... }:

let
  enabled = (userState.languages.python or false) || (userState.frameworks.django or false);
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      (python3.withPackages (ps: with ps; [
        pip
        virtualenv
      ]))
    ];
  };
}
