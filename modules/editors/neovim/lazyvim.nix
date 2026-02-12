{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.lazyvim or false;
in
{
  config = lib.mkIf enabled {
    # LazyVim often expects files in lua/plugins, lua/config
    xdg.configFile."nvim/lua/config/cafaye-defaults.lua".text = ''
      -- Cafaye defaults for LazyVim
      return {}
    '';
    
    # User linkage
    xdg.configFile."nvim/lua/plugins/user.lua".source = ../../../config/user/nvim/lazyvim/plugins/user.lua;
    xdg.configFile."nvim/lua/config/options.lua".source = ../../../config/user/nvim/lazyvim/options.lua;
    xdg.configFile."nvim/lua/config/keymaps.lua".source = ../../../config/user/nvim/lazyvim/keymaps.lua;
  };
}
