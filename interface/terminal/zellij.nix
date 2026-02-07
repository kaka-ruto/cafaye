{ config, pkgs, userState, ... }:

let
  zellijEnabled = userState.interface.terminal.multiplexer == "zellij";
in
{
  # If programs.zellij is not in NixOS (it might be HM only), we use environment.systemPackages
  environment.systemPackages = if zellijEnabled then [ pkgs.zellij ] else [];

  # Auto-start Zellij on SSH login if desired
  # We use a helper script or just the zsh init
  programs.zsh.interactiveShellInit = if zellijEnabled then ''
    if [[ -z "$ZELLIJ" && "$SSH_CONNECTION" != "" ]]; then
      exec ${pkgs.zellij}/bin/zellij attach -c
    fi
  '' else "";
}
