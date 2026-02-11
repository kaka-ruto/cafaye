{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.lunarvim or false;
in
{
  # LunarVim auto-enables neovim
}
