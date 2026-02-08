{ config, pkgs, userState, ... }:

let
  enabled = userState.editors.neovim or false;
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      neovim
      git
      gcc
      gnumake
      unzip
      wget
      curl
      ripgrep
      fd
      tree-sitter
    ]
  );

  # Symlink default config if it doesn't exist (handled by CLI scripts usually, 
  # but we can provide a system-wide default or home-manager style link)
  # For now, we'll let the caf-config-init handle it to allow user customization.
}
