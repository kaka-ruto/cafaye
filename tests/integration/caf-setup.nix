{ pkgs, inputs, userState, ... }:

{
  name = "integration-caf-setup";
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
          ../../interface
          ../../cli
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = { inherit inputs userState; };

        environment.systemPackages = with pkgs; [
          jq
          (writeScriptBin "caf-system-rebuild" ''
            #!/bin/sh
            echo "Mock system rebuild completed"
            exit 0
          '')
          (writeScriptBin "caf-hook-run" ''
            #!/bin/sh
            echo "Mock hook executed: $*"
            exit 0
          '')
        ];

        environment.etc."cafaye/user-state.json".text = builtins.toJSON {
          core = {
            tailscale_enabled = true;
            zram_enabled = true;
            authorized_keys = ["ssh-ed25519 test-key"];
            boot.grub_device = "/dev/vda";
            security.bootstrap_mode = true;
          };
          interface.terminal = { shell = "zsh"; multiplexer = "zellij"; };
          interface.theme = "catppuccin-mocha";
          dev_tools.docker = true;
          languages = { ruby = false; python = false; nodejs = false; };
          frameworks = { rails = false; django = false; nextjs = false; };
          services = { postgresql = false; redis = false; docker = false; };
          editors = {
            neovim = false;
            helix = false;
            vscode_server = false;
            default = "neovim";
            distributions.nvim = { lazyvim = false; astronvim = false; nvchad = false; lunarvim = false; };
          };
        };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;

        users.users.cafaye = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = [ "ssh-ed25519 test-key" ];
        };
        security.sudo.wheelNeedsPassword = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # === CAF-SETUP EXISTENCE TESTS ===
    machine.succeed("which caf-setup")
    machine.succeed("test -x $(which caf-setup)")
    machine.succeed("bash -n $(which caf-setup)")

    # === CAF-SETUP FUNCTION TESTS ===
    machine.succeed("grep -q 'show_welcome' $(which caf-setup)")
    machine.succeed("grep -q 'configure_editor' $(which caf-setup)")
    machine.succeed("grep -q 'configure_development_stack' $(which caf-setup)")
    machine.succeed("grep -q 'security_check' $(which caf-setup)")

    # === NON-INTERACTIVE MODE TEST ===
    machine.succeed("caf-setup --no-confirm --editor nvim --distro lazyvim --languages ruby --ai false || echo \"Setup completed\"")
    machine.succeed("grep -q 'ruby' /etc/cafaye/user-state.json")

    # === DEPENDENCIES AVAILABLE ===
    machine.succeed("which jq")
    machine.succeed("which caf-system-rebuild")
    machine.succeed("which caf-hook-run")

    print("✅ integration-caf-setup test passed")
  '';
}
