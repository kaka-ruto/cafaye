{ pkgs, lib, ... }:

{
  # Global fixes for behavioral tests running in sandboxed environments
  
  # Disable the problematic Darwin font module entirely
  disabledModules = [ "targets/darwin/fonts.nix" ];

  # Standard fixes
  fonts.fontconfig.enable = lib.mkForce false;
  
  # Ensure the test user has a stable state version
  home.stateVersion = lib.mkDefault "24.11";
  
  home.username = lib.mkForce "test-user";
  home.homeDirectory = lib.mkForce "/home/test-user";
}
