{ config, pkgs, inputs, userState, ... }:

{
  imports = [
    ./theme.nix
    ./tools.nix
    ./terminal/zsh.nix
    ./terminal/starship.nix
    ./terminal/zellij.nix
    ./terminal/btop.nix
    ./terminal/lazygit.nix
    ./terminal/fastfetch.nix
    ./ide
  ];

  # Global branding deployment
  environment.etc."cafaye/branding/about.txt".source = ../config/cafaye/branding/about.txt;
}
