{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.nvchad or false;
in
{
  # NvChad auto-enables neovim
}
