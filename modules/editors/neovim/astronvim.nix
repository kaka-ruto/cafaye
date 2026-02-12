{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.astronvim or false;
in
{
  config = lib.mkIf enabled {
    xdg.configFile."nvim/lua/user".source = ../../../config/user/nvim/astronvim;
  };
}
