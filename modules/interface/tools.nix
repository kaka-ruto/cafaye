{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Navigation & Search
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
  ];

  # Modern alternatives enabled via HM
  programs.zoxide.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Basic aliases to encourage using the new tools
  home.shellAliases = {
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -la --icons --group-directories-first";
    cat = "bat";
    grep = "rg";
  };
}
