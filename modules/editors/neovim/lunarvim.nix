{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.lunarvim or false;
in
{
  config = lib.mkIf enabled {
    # LunarVim uses ~/.config/lvim
    home.file.".config/lvim".source = ../../../config/user/nvim/lunarvim;
  };
}
