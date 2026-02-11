{ config, pkgs, lib, userState, ... }:

let
  # Each module should have a way to enable/disable it from userState
  # This matches the user's environment choices in environment.json
  # NOTE: Every module at modules/category/name.nix MUST have a 
  # corresponding test at tests/modules/category/name.nix for evaluation.
  enabled = userState.category.tool or false;
in
{
  # Only add packages if the module is enabled
  home.packages = lib.optionals enabled [
    # pkgs.tool-name
  ];

  # Optional: Module-specific configuration (git aliases, shell aliases, etc)
  # home.file.".tool-config".text = ''
  #   config content
  # '';
}
