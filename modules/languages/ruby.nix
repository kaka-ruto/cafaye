{ config, pkgs, lib, userState, ... }:

let
  enabled = (userState.languages.ruby or false) || (userState.frameworks.rails or false);
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      ruby_3_3
      
      # Essential headers for native gems
      zlib
      libxml2
      libxslt
      pkg-config
      
      # DB clients (needed for 'pg' and 'mysql2' gems)
      postgresql_16
      mariadb.client
    ];
  };
}
