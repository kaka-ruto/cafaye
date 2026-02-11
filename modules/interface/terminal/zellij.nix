{ config, pkgs, lib, userState, ... }:

let
  zellijEnabled = (userState.interface.terminal.multiplexer or "zellij") == "zellij";
in
{
  programs.zellij = {
    enable = zellijEnabled;
    # enableZshIntegration = true; # We'll handle it manually for better control
  };

  # Deploy the config file (we'll look into dotfiles later, for now we just enable it)
  # home.file.".config/zellij/config.kdl".source = ../../../config/terminal/zellij.kdl;
}
