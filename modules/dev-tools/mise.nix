{ config, pkgs, userState, ... }:

{
  environment.systemPackages = with pkgs; [
    mise
  ];

  # Hook mise into shells
  programs.bash.interactiveShellInit = ''
    eval "$(${pkgs.mise}/bin/mise activate bash)"
  '';
  programs.zsh.interactiveShellInit = ''
    eval "$(${pkgs.mise}/bin/mise activate zsh)"
  '';
}
