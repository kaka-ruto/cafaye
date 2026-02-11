{ config, pkgs, ... }:

{
  # Custom Message of the Day (MOTD)
  users.motd = ''
    
    ☕ Welcome to Cafaye OS!
    -------------------------------------------
    The cloud-native developer powerhouse.
    
    Architecture:  ${pkgs.stdenv.hostPlatform.system}
    NixOS Version: ${config.system.nixos.release}
    
    Type 'caf' to start the management console.
    
    Happy coding!
    -------------------------------------------
  '';
}
