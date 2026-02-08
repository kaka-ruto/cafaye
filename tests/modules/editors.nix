{ pkgs, inputs, userState, ... }:

{
  name = "modules-editors";
  nodes = {
    machine = { ... }:
      {
        imports = [
          ../../core/boot.nix
          ../../core/hardware.nix
          ../../core/network.nix
          ../../core/security.nix
          ../../core/sops.nix
          ../../core/user.nix
          ../../modules
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = { inherit inputs userState; };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    ${pkgs.lib.optionalString (userState.editors.neovim or false) ''
      # Test Neovim
      machine.succeed("nvim --version")
    ''}

    ${pkgs.lib.optionalString (userState.editors.helix or false) ''
      # Test Helix
      machine.succeed("hx --version")
    ''}

    # Test support tools (should be present if interface/tools.nix is imported)
    machine.succeed("rg --version")
    machine.succeed("fd --version")
  '';
}
