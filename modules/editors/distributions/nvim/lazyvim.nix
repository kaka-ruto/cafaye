{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.lazyvim or false;
in
{
  # LazyVim auto-enables neovim
  # The actual LazyVim setup is done via the CLI script caf-nvim-distribution-setup
  # which clones the starter template and applies theme customizations
}
