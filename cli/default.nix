{ pkgs, ... }:

let
  caf-cli = pkgs.stdenv.mkDerivation {
    name = "caf-cli";
    src = ./.;
    installPhase = ''
      mkdir -p $out/bin
      cp main.sh $out/bin/caf
      chmod +x $out/bin/caf
      
      # Copy scripts
      cp -r scripts/* $out/bin/
      chmod +x $out/bin/caf-*
      # Also chmod the helpers if any
      chmod +x $out/bin/*.sh
    '';
  };
in
{
  environment.systemPackages = [ 
    caf-cli
    pkgs.gum
  ];
}
