{ config, pkgs, inputs, userState, ... }:

{
  imports = [
    ./tools.nix
    ./terminal/zsh.nix
    ./terminal/starship.nix
    ./terminal/zellij.nix
  ];
}
