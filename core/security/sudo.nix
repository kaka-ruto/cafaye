{ config, pkgs, userState, ... }:

{
  # Sudo hardening
  security.sudo.extraConfig = ''
    Defaults use_pty
  '';
}
