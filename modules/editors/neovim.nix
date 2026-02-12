{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.editors.neovim or true;
  
  # Distribution states
  dists = userState.editors.distributions.nvim or {};
  hasDistro = (dists.lazyvim or false) || (dists.astronvim or false) || (dists.nvchad or false) || (dists.lunarvim or false);
  
  # Helper to read optional config files
  readConfig = path: if builtins.pathExists path then builtins.readFile path else "";
  
  # Configuration layers (Base)
  baseDefaultConfig = readConfig ../../../config/cafaye/nvim/base/init.lua;
  # Note: This is the non-distro user init.lua
  baseUserConfig = readConfig ../../../config/user/nvim/init.lua;
in
{
  programs.neovim = {
    enable = enabled;
    defaultEditor = (userState.editors.default or "neovim") == "neovim";
    viAlias = true;
    vimAlias = true;
    
    # Dependencies for modern Neovim distros
    extraPackages = with pkgs; [
      # Compilation & Build
      git
      gcc
      gnumake
      unzip
      wget
      curl
      
      # Search & Navigation
      ripgrep
      fd
      fzf
      
      # Language Servers & Tooling (Basics)
      tree-sitter
      lua-language-server
      nodePackages.bash-language-server
      stylua # Lua formatter
      
      # Node.js (often needed for copilot/coc/certain LSPs)
      pkgs.nodejs
    ];
    
    # If no distro, we use our base layered config
    extraConfig = lib.mkIf (enabled && !hasDistro) ''
      -- --- [ LAYER 1: CAFAYE DEFAULTS ] ---
      ${baseDefaultConfig}
      
      -- --- [ LAYER 2: USER OVERRIDES ] ---
      ${baseUserConfig}
    '';
  };
}
