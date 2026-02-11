{ pkgs, inputs, home-module, ... }:

let
  userState = {
    interface = { terminal = { fastfetch = true;  }; };
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
