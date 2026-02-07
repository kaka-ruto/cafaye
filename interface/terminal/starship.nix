{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    # Native starship settings
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      # We will customize this further with the Catppuccin theme in the next steps
    };
  };
}
