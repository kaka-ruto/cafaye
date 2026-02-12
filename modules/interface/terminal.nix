{ config, pkgs, lib, userState, ... }:

{
  imports = [
    ./terminal/zsh.nix
    ./terminal/starship.nix
    ./terminal/zellij.nix
    ./terminal/ghostty.nix
    ./terminal/btop.nix
    ./terminal/fastfetch.nix
    ./terminal/lazygit.nix
  ];
}
