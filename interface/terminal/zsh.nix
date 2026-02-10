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

    shellAliases = {
      # Base shortcuts
      l = "eza -lh --icons";
      ls = "eza --icons";
      ll = "eza -alHh --icons";
      cat = "bat";
      top = "btop";
      
      # Cafaye CLI
      apply = "caf apply";
      test = "caf test";
    } // (pkgs.lib.optionalAttrs (userState.languages.ruby or false || userState.frameworks.rails or false) {
      r = "bundle exec rails";
      rs = "bundle exec rails server";
      rc = "bundle exec rails console";
      be = "bundle exec";
    }) // (pkgs.lib.optionalAttrs (userState.languages.rust or false) {
      c = "cargo";
      cb = "cargo build";
      cr = "cargo run";
      ct = "cargo test";
    }) // (pkgs.lib.optionalAttrs (userState.languages.nodejs or false) {
      n = "npm";
      nr = "npm run";
      ni = "npm install";
    });

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
