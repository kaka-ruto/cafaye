#!/bin/bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
cd "$PROJECT_ROOT"

MODULES=$(find modules -name "*.nix" | grep -v "default.nix" | grep -v "_template.nix")

for mod in $MODULES; do
    if [[ "$mod" == "modules/languages/ruby.nix" || "$mod" == "modules/interface/tools.nix" ]]; then
        continue
    fi
    
    # Path inside repo
    test_file="tests/$mod"
    mkdir -p "$(dirname "$test_file")"
    
    # Extract category and tool from path
    category=$(echo "$mod" | cut -d'/' -f2)
    # Handle subdirectories eg modules/editors/neovim/lazyvim.nix
    if [[ "$mod" == *"/"*"/"*"/"* ]]; then
        # Category is still editors
        # Tool name should reflect subpath eg editors.neovim.lazyvim
        tool_path=$(echo "$mod" | cut -d'/' -f3- | sed 's/\.nix$//' | tr '/' '.')
        full_key="$category.$tool_path"
    else
        tool=$(echo "$mod" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
        full_key="$category.$tool"
    fi
    
    echo "🧪 Generating test for $mod (key: $full_key)..."
    
    cat > "$test_file" <<EOF
{ pkgs, inputs, home-module, ... }:

let
  userState = {
    $(echo $full_key | sed 's/\./ = { /g' | sed 's/$/ = true; /')$(echo $full_key | tr -cd '.' | sed 's/\./ };/g')
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    home-module
    {
      home.username = pkgs.lib.mkForce "test";
      home.homeDirectory = pkgs.lib.mkForce "/home/test";
      home.stateVersion = pkgs.lib.mkForce "24.11";
    }
  ];
  extraSpecialArgs = { inherit inputs userState; };
}
EOF
done
