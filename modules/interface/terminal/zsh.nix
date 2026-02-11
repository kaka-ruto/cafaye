{ config, pkgs, lib, userState, ... }:

let 
  shellEnabled = (userState.interface.terminal.shell or "zsh") == "zsh";
in
{
  programs.zsh = {
    enable = shellEnabled;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "direnv" ];
    };

    shellAliases = lib.mkForce ({
      # Base shortcuts
      l = "eza -lh --icons";
      ls = "eza --icons";
      ll = "eza -alHh --icons";
      cat = "bat";
      top = "btop";
      
      # Cafaye CLI
      apply = "caf apply";
      test = "caf test";
    } // (lib.optionalAttrs (userState.languages.ruby or false || userState.frameworks.rails or false) {
      r = "bundle exec rails";
      rs = "bundle exec rails server";
      rc = "bundle exec rails console";
      be = "bundle exec";
    }) // (lib.optionalAttrs (userState.languages.rust or false) {
      c = "cargo";
      cb = "cargo build";
      cr = "cargo run";
      ct = "cargo test";
    }) // (lib.optionalAttrs (userState.languages.nodejs or false) {
      n = "npm";
      nr = "npm run";
      ni = "npm install";
    }));

    # Initialize starship and zoxide
    initContent = ''
      # Greet with fastfetch if interactive
      if [[ $- == *i* ]]; then
        # fastfetch --config ~/.config/cafaye/fastfetch/config.jsonc
        
        # Auto-start Zellij if not already inside a session
        if [[ -z "$ZELLIJ" ]]; then
          if [[ "$ZELLIJ_AUTO_ATTACH" != "false" ]]; then
            # zellij attach -c cafaye || zellij
          fi
        fi
      fi
    '';
  };
}
