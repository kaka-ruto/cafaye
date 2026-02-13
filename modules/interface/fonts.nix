{ pkgs, ... }:

{
  # Nerd fonts for terminal/editor UX.
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
