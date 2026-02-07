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
    fastfetch    # System info display
    
    # System & Processing
    btop         # Resource monitor
    jq           # JSON processor
    
    # Development
    git          # Version control
    lazygit      # Git TUI
  ];

  # Basic aliases to encourage using the new tools
  environment.shellAliases = {
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -la --icons --group-directories-first";
    cat = "bat";
    grep = "rg";
    top = "btop";
    cd = "z"; # Using zoxide
  };
}
