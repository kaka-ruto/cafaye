{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.astronvim or false;
in
{
  # AstroNvim auto-enables neovim
  # The actual AstroNvim setup is done via the CLI script caf-nvim-distribution-setup
}
