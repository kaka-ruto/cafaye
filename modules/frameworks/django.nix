{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.frameworks.django or false;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      # Standard dependencies for Django/Python development
      libffi
      openssl
      
      # DB clients (needed for 'psycopg2' etc.)
      postgresql.lib
    ];
  };
}
