{ lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  currentUser = "kaka";
  currentHome = if isDarwin then "/Users/kaka" else "/home/kaka";
in
{
  # Machine-local identity for the maintainer environment.
  home.username = lib.mkDefault currentUser;
  home.homeDirectory = lib.mkDefault currentHome;
  home.stateVersion = "24.11";
}
