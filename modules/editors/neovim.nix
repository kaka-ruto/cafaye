{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.neovim or false;
in
{
  programs.neovim = {
    enable = enabled;
    defaultEditor = userState.editors.default == "neovim";
    viAlias = true;
    vimAlias = true;
    
    extraPackages = with pkgs; [
      git
      gcc
      gnumake
      unzip
      wget
      curl
      ripgrep
      fd
      tree-sitter
      lua-language-server
    ];
  };
}
