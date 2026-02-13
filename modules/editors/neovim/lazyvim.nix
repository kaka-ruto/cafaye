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
    xdg.configFile."nvim/lua/plugins/user.lua" = {
      source = ../../../config/user/nvim/lazyvim/plugins/user.lua;
      force = true;
    };
    xdg.configFile."nvim/lua/config/options.lua" = {
      source = ../../../config/user/nvim/lazyvim/options.lua;
      force = true;
    };
    xdg.configFile."nvim/lua/config/keymaps.lua" = {
      source = ../../../config/user/nvim/lazyvim/keymaps.lua;
      force = true;
    };
    xdg.configFile."nvim/lua/config/autocmds.lua" = {
      source = ../../../config/user/nvim/lazyvim/autocmds.lua;
      force = true;
    };
  };
}
