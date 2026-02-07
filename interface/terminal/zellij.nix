{ config, pkgs, userState, ... }:

let
  zellijEnabled = userState.interface.terminal.multiplexer == "zellij";
  configDir = "/etc/cafaye/zellij";
in
{
  environment.systemPackages = if zellijEnabled then [ pkgs.zellij ] else [];

  # Deploy the config file
  environment.etc."cafaye/zellij/config.kdl".source = ../../config/themes/catppuccin/zellij.kdl;

  # Auto-start Zellij on SSH login if desired
  programs.zsh.interactiveShellInit = if zellijEnabled then ''
    if [[ -z "$ZELLIJ" && "$SSH_CONNECTION" != "" ]]; then
      exec ${pkgs.zellij}/bin/zellij --config ${configDir}/config.kdl attach -c
    fi
  '' else "";
}
