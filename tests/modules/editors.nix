{ pkgs, inputs, userState, ... }:

let
  testState = userState // {
    editors = {
      neovim = true;
      helix = true;
      vscode_server = false;  # Skip code-server to avoid long build times
      default = "neovim";
    };
  };
in
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
        _module.args = { inherit inputs; userState = testState; };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Test Neovim
    machine.succeed("nvim --version")

    # Test Helix
    machine.succeed("hx --version")

    # Test support tools
    machine.succeed("rg --version")
    machine.succeed("fd --version")
  '';
}
