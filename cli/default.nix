{ pkgs, userState, ... }:

let
  caf-cli = pkgs.callPackage ./package.nix { };
in
{
  environment.systemPackages = [
    caf-cli
    pkgs.gum
    pkgs.jq
    pkgs.git
  ];

  # Initial user state for the system
  environment.etc."cafaye/user/user-state.json".text = builtins.toJSON userState;
}
