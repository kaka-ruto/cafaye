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
    mise         # Polyglot runtime manager (asdf successor)
  ] ++ (with pkgs; [
    # Git/Docker TUI improvements
    delta
  ]) ++ (if pkgs ? lazydocker then [ pkgs.lazydocker ] else [])
    ++ (if pkgs ? git-standup then [ pkgs.git-standup ] else []);

  # Modern alternatives enabled via HM
  programs.zoxide.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
