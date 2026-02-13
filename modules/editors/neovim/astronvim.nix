{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.astronvim or false;
in
{
  config = lib.mkIf enabled {
    # AstroNvim v4+ structure linkage
    # We link the core files into ~/.config/nvim/lua/
    xdg.configFile = {
      "nvim/init.lua" = {
        source = ../../../config/user/nvim/astronvim/init.lua;
        force = true;
      };
      "nvim/lua/plugins" = {
        source = ../../../config/user/nvim/astronvim/plugins;
        force = true;
      };
      "nvim/lua/polish.lua" = {
        source = ../../../config/user/nvim/astronvim/polish.lua;
        force = true;
      };
      "nvim/lua/community.lua" = {
        source = ../../../config/user/nvim/astronvim/community.lua;
        force = true;
      };
      "nvim/lua/lazy_setup.lua" = {
        source = ../../../config/user/nvim/astronvim/lazy_setup.lua;
        force = true;
      };
      "nvim/lua/user" = {
        source = ../../../config/user/nvim/astronvim;
        force = true;
      };
    };
  };
}
