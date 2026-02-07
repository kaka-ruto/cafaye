{ config, pkgs, userState, ... }:

let
  enabled = userState.languages.python or false;
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      poetry
    ]
  );
}
