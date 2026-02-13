{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.interface.terminal.lazygit.enable or true;
  
  # Paths to our staged config files
  # We use the literal paths since they will be symlinked into ~/.config/cafaye/config/...
  cafayeConfig = "$HOME/.config/cafaye/config/cafaye/lazygit/config.yml";
  userConfig = "$HOME/.config/cafaye/config/user/lazygit/config.yml";
in
{
  config = lib.mkIf enabled {
    programs.lazygit = {
      enable = true;
    };

    home.sessionVariables = {
      # Use the multiple config file support in lazygit
      LG_CONFIG_FILE = "${cafayeConfig},${userConfig}";
    };

    home.activation.cafayeLazygitSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config"
      if [ -d "$HOME/.config/lazygit" ] && [ ! -L "$HOME/.config/lazygit" ]; then
        rm -rf "$HOME/.config/lazygit"
      fi
      ln -sfn "$HOME/.config/cafaye/config/cafaye/lazygit" "$HOME/.config/lazygit"
    '';
  };
}
