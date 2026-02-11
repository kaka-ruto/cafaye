{ config, pkgs, lib, userState, ... }:

let
  enabled = (userState.languages.ruby or false) || (userState.frameworks.rails or false);
in
{
  home.packages = lib.optionals enabled (
    with pkgs; [
      ruby
      # bundler & rake (included in ruby)
    ]
  );
}
