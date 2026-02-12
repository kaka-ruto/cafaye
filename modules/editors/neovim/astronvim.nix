{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.distributions.nvim.astronvim or false;
in
{
  config = lib.mkIf enabled {
    # AstroNvim v4+ structure linkage
    # We link the core files into ~/.config/nvim/lua/
    xdg.configFile = {
      "nvim/init.lua".source = ../../../config/user/nvim/astronvim/init.lua;
      "nvim/lua/plugins".source = ../../../config/user/nvim/astronvim/plugins;
      "nvim/lua/polish.lua".source = ../../../config/user/nvim/astronvim/polish.lua;
      "nvim/lua/community.lua".source = ../../../config/user/nvim/astronvim/community.lua;
      "nvim/lua/lazy_setup.lua".source = ../../../config/user/nvim/astronvim/lazy_setup.lua;
    };
  };
}
