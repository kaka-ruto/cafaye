{ config, pkgs, ... }:

{
  home.packages = [ pkgs.fastfetch ];
  # config will be added later
}
