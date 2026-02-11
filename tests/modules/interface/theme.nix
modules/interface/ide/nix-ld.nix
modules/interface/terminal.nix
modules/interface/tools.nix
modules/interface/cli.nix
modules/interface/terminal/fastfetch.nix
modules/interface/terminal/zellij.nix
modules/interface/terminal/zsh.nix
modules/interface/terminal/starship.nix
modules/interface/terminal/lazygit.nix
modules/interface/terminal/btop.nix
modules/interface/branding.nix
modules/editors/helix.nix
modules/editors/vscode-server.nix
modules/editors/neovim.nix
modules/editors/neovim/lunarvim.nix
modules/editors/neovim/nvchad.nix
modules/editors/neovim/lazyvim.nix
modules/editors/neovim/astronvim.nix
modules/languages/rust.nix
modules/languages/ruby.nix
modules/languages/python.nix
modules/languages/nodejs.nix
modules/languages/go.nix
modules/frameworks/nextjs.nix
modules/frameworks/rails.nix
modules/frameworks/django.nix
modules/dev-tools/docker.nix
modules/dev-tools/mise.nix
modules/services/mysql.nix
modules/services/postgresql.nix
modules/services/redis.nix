{ pkgs, inputs, home-module, ... }:
let
  userState = {
    interface
interface
interface
interface
interface
interface
interface
interface
interface
interface
interface
interface
editors
editors
editors
editors
editors
editors
editors
languages
languages
languages
languages
languages
frameworks
frameworks
frameworks
dev-tools
dev-tools
services
services
services.theme
nix-ld
terminal
tools
cli
fastfetch
zellij
zsh
starship
lazygit
btop
branding
helix
vscode-server
neovim
lunarvim
nvchad
lazyvim
astronvim
rust
ruby
python
nodejs
go
nextjs
rails
django
docker
mise
mysql
postgresql
redis = true;
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
