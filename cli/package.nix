{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "caf-cli";
  version = "0.9.0";
  src = ./.;
  
  installPhase = ''
    mkdir -p $out/bin
    cp main.sh $out/bin/caf
    
    # Copy scripts
    if [ -d scripts ]; then
      cp -r scripts/* $out/bin/
    fi

    if [ -d bin ]; then
      cp -r bin/* $out/bin/
    fi

    # Make everything in bin executable
    find $out/bin -type f -exec chmod +x {} +
  '';
}
