{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.helix or false;
in
{
  config = lib.mkIf enabled {
    programs.helix = {
      enable = true;
      defaultEditor = (userState.editors.default or "neovim") == "helix";
      settings = {
        theme = "catppuccin_mocha";
        editor = {
          line-number = "relative";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
        };
      };
    };
  };
}
