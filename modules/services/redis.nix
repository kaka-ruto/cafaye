{ config, pkgs, userState, ... }:

let
  enabled = (userState.services.redis or false) || (userState.frameworks.rails or false) || (userState.frameworks.django or false);
in
{
  services.redis.servers.default = {
    enable = enabled;
    port = 6379;
    bind = "127.0.0.1";
  };

  environment.systemPackages = pkgs.lib.optional enabled pkgs.redis;
}
