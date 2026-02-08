{ pkgs, inputs, userState, ... }:

{
  name = "modules-editors-distributions";
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

    # Test Neovim is available (distributions enable neovim)
    # Check if ANY neovim distribution is enabled
    ${pkgs.lib.optionalString (
        (userState.editors.neovim or false) ||
        (userState.editors.distributions.nvim.lazyvim or false) ||
        (userState.editors.distributions.nvim.astronvim or false) ||
        (userState.editors.distributions.nvim.nvchad or false) ||
        (userState.editors.distributions.nvim.lunarvim or false)
      ) ''
      machine.succeed("nvim --version")
    ''}
    
    # Test git is available (needed for distribution setup)
    machine.succeed("git --version")
  '';
}
