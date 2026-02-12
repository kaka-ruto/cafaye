{ config, pkgs, lib, userState, ... }:

let 
  shellEnabled = (userState.interface.terminal.shell or "zsh") == "zsh";
  
  # Helper to read optional config files
  readConfig = path: if builtins.pathExists path then builtins.readFile path else "";
  
  # Configuration layers
  defaultConfig = readConfig ../../../config/cafaye/zsh/config.zsh;
  userConfig = readConfig ../../../config/user/zsh/custom.zsh;
in
{
  programs.zsh = {
    enable = shellEnabled;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "direnv" ] 
                ++ (lib.optional (userState.languages.ruby or false || userState.frameworks.rails or false) "ruby")
                ++ (lib.optional (userState.languages.ruby or false || userState.frameworks.rails or false) "bundler");
    };

    shellAliases = {
      # Base shortcuts
      l = "eza -lh --icons";
      ls = "eza --icons";
      ll = "eza -alHh --icons";
      cat = "bat";
      top = "btop";
      
      # Git Aliases (Reintroduced by user feedback)
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit -m";
      gca = "git commit --amend";
      gp = "git push";
      gpl = "git pull";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gst = "git status";
      
      # Cafaye CLI
      apply = "caf apply";
      test = "caf test";
    };

    # Two-layer Zsh initialization
    initContent = ''
      # ═══════════════════════════════════════════════════════════════════
      # CAFAYE ZSH INITIALIZATION
      # ═══════════════════════════════════════════════════════════════════
      
      # --- [ LAYER 1: CAFAYE DEFAULTS ] ---
      ${defaultConfig}
      
      # Initialize Version Managers
      if command -v mise &> /dev/null; then
        eval "$(mise activate zsh)"
      fi
      
      # --- [ LAYER 2: USER CUSTOMIZATIONS ] ---
      # Sourced from ~/.config/cafaye/config/user/zsh/custom.zsh
      ${userConfig}
      
      # Starship & Zoxide initialization (handled by HM but listed here for context)
    '';
  };
}
