{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.nvchad or false;
in
{
  config = lib.mkIf enabled {
    xdg.configFile."nvim/lua/custom".source = ../../../config/user/nvim/nvchad;
  };
}
