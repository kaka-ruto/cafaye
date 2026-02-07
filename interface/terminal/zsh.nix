{ config, pkgs, userState, ... }:

let 
  shellEnabled = userState.interface.terminal.shell == "zsh";
in
{
  programs.zsh = {
    enable = shellEnabled;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "direnv" ];
    };

    # Initialize starship and zoxide
    interactiveShellInit = ''
      export STARSHIP_CONFIG=/etc/cafaye/terminal/starship.toml
      eval "$(${pkgs.starship}/bin/starship init zsh)"
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      
      # Greet with fastfetch if interactive
      if [[ $- == *i* ]]; then
        fastfetch --config /etc/cafaye/fastfetch/config.jsonc
        
        # Auto-start Zellij if not already inside a session
        if [[ -z "$ZELLIJ" ]]; then
          if [[ "$ZELLIJ_AUTO_ATTACH" != "false" ]]; then
            zellij attach -c cafaye || zellij
          fi
        fi
      fi
    '';
  };

  # Set Zsh as default shell for the cafaye user
  users.users.cafaye.shell = pkgs.zsh;
}
