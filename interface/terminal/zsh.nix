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
      
      # Greet with fastfetch if interactive
      if [[ $- == *i* ]]; then
        fastfetch --config /etc/cafaye/fastfetch/config.jsonc
      fi
    '';
  };

  # Set Zsh as default shell for the cafaye user
  users.users.cafaye = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = "cafaye";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  users.groups.cafaye = {};
}
