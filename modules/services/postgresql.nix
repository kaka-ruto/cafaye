{ config, pkgs, userState, ... }:

let
  enabled = (userState.services.postgresql or false) || (userState.frameworks.rails or false) || (userState.frameworks.django or false);
in
{
  services.postgresql = {
    enable = enabled;
    package = pkgs.postgresql_16;
    ensureDatabases = [ "cafaye" ];
    ensureUsers = [
      {
        name = "cafaye";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      # type database  user  address     method
      local all       all               trust
      host  all       all  127.0.0.1/32 trust
      host  all       all  ::1/128      trust
    '';
  };

  environment.systemPackages = pkgs.lib.optional enabled pkgs.postgresql_16;
}
