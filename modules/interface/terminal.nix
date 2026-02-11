{ config, pkgs, lib, userState, ... }:

{
  imports = [
    ./terminal/zsh.nix
    ./terminal/starship.nix
    ./terminal/zellij.nix
    ./terminal/btop.nix
    ./terminal/fastfetch.nix
    ./terminal/lazygit.nix
  ];
}
