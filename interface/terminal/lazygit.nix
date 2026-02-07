{ config, pkgs, palette, ... }:

let
  lgConfig = {
    gui = {
      theme = {
        activeBorderColor = [ palette.blue "bold" ];
        inactiveBorderColor = [ palette.surface1 ];
        searchingActiveBorderColor = [ palette.yellow "bold" ];
        optionsTextColor = [ palette.blue ];
        selectedLineBgColor = [ palette.surface0 ];
        selectedRangeBgColor = [ palette.surface0 ];
        cherryPickedCommitBgColor = [ palette.surface1 ];
        cherryPickedCommitFgColor = [ palette.mauve ];
        unstagedChangesColor = [ palette.red ];
        defaultFgColor = [ palette.text ];
      };
    };
  };
in
{
  environment.systemPackages = [ pkgs.lazygit ];

  environment.etc."cafaye/lazygit/config.yml".text = builtins.toJSON lgConfig;

  environment.shellAliases = {
    lg = "lazygit --config /etc/cafaye/lazygit/config.yml";
  };
}
