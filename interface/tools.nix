{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Navigation & Search
    zoxide       # Smart cd
    fzf          # Fuzzy finder
    fd           # Fast find
    ripgrep      # Fast grep
    
    # File Viewers & Info
    eza          # Modern ls
    bat          # Modern cat
    tree         # Directory tree
    
    # System & Processing
    jq           # JSON processor
    
    # Development
    git          # Version control
    direnv       # Env auto-loader
    nix-direnv   # Faster nix shells for direnv
  ];

  # Basic aliases to encourage using the new tools
  environment.shellAliases = {
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -la --icons --group-directories-first";
    cat = "bat";
    grep = "rg";
    cd = "z"; # Using zoxide
  };
}
