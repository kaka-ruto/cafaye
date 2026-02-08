{ config, pkgs, userState, ... }:

let
  enabled = userState.frameworks.nextjs or false;
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      vips
      pkg-config
    ]
  );
}
