{ pkgs, inputs, userState, ... }:

let
  testState = userState // {
    editors = {
      neovim = true;
      helix = false;
      vscode_server = false;
      default = "neovim";
      distributions = {
        nvim = {
          lazyvim = true;
          astronvim = false;
          nvchad = false;
          lunarvim = false;
        };
      };
    };
  };
in
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
        _module.args = { inherit inputs; userState = testState; };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Test Neovim is available (distributions enable neovim)
    machine.succeed("nvim --version")
    
    # Test git is available (needed for distribution setup)
    machine.succeed("git --version")
  '';
}
