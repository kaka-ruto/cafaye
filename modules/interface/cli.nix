{ config, pkgs, ... }:

let
  cafaye-scripts = pkgs.stdenv.mkDerivation {
    name = "cafaye-scripts";
    src = ../../cli;
    installPhase = ''
      mkdir -p $out/bin
      cp -r scripts/* $out/bin/
      chmod +x $out/bin/*
      
      # Create the main 'caf' wrapper
      cat > $out/bin/caf <<EOF
#!/bin/bash
CAFAYE_DIR="\$HOME/.config/cafaye"
if [ ! -d "\$CAFAYE_DIR" ]; then
  echo "❌ Cafaye directory not found at \$CAFAYE_DIR"
  exit 1
fi
PATH="\$out/bin:\$PATH" exec bash "\$CAFAYE_DIR/cli/main.sh" "\$@"
EOF
      chmod +x $out/bin/caf
    '';
  };
in
{
  home.packages = [ cafaye-scripts ];
}
