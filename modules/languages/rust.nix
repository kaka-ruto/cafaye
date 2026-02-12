{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.languages.rust or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      rustup # Recommended for managing multiple toolchains
      # or just the base if preferred:
      # cargo
      # rustc
    ];
  };
}
