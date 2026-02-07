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

    # Initialize zoxide
    interactiveShellInit = ''
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      
      # Greet with fastfetch if interactive
      if [[ $- == *i* ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };

  # Set Zsh as default shell for the cafaye user
  users.users.cafaye.shell = pkgs.zsh;
}
