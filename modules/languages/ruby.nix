{ config, pkgs, userState, ... }:

let
  enabled = userState.languages.ruby or false;
in
{
  environment.systemPackages = pkgs.lib.optionals enabled (
    with pkgs; [
      ruby
      bundler
      rake
    ]
  );
}
