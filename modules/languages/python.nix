{ config, pkgs, lib, userState, ... }:

let
  enabled = (userState.languages.python or false) || (userState.frameworks.django or false);
in
{
  home.packages = lib.optionals enabled (
    with pkgs; [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      poetry
    ]
  );
}
