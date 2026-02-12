{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.interface.terminal.ghostty.enable or true;
in
{
  # We'll stick to a simpler structure for now as per the existing modules
  config = lib.mkIf enabled {
    home.packages = [ pkgs.ghostty ];
    
    # Ghostty configuration usually goes in ~/.config/ghostty/config
    # We'll use Home Manager's xdg.configFile if Ghostty doesn't have a direct HM module yet
    xdg.configFile."ghostty/config" = {
      text = ''
        theme = catppuccin-mocha
        font-family = "JetBrainsMono Nerd Font"
        font-size = 12
        
        # Omarchy aesthetic
        window-decoration = false
        window-padding-x = 8
        window-padding-y = 8
        
        # Performance
        cursor-style = block
        cursor-blink = false
      '';
    };
  };
}
