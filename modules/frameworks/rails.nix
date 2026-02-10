{ config, pkgs, userState, ... }:

let
  enabled = userState.frameworks.rails or false;
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      libyaml
      vips
      pkg-config
      libxml2
      libxslt
      readline
      sqlite
      rubyPackages.rails
    ]
  );
}
