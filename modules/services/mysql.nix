{ config, pkgs, userState, ... }:

let
  enabled = userState.services.mysql or false;
in
{
  services.mysql = {
    enable = enabled;
    package = pkgs.mariadb;
    ensureDatabases = [ "cafaye" ];
    ensureUsers = [
      {
        name = "cafaye";
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }
    ];
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
      };
    };
  };

  # For MariaDB, we might need to manually set the plugin if we wanted 'trust' 
  # but 'ensureUsers' doesn't easily support 'IDENTIFIED VIA' in the simple nixos module.
  # However, common dev practice is unix socket or no password for local.


  environment.systemPackages = pkgs.lib.optional enabled pkgs.mariadb;
}
