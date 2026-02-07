{ pkgs, userState, ... }:

let
  caf-cli = pkgs.stdenv.mkDerivation {
    name = "caf-cli";
    src = ./.;
    installPhase = ''
      mkdir -p $out/bin
      cp main.sh $out/bin/caf
      
      # Copy scripts
      if [ -d scripts ]; then
        cp -r scripts/* $out/bin/
      fi

      # Make everything in bin executable
      find $out/bin -type f -exec chmod +x {} +
    '';
  };
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
