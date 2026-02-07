{ pkgs, inputs, userState, ... }:

{
  name = "interface-terminal";
  nodes = {
    machine = {
      imports = [ 
        ../../core/boot.nix
        ../../core/hardware.nix
        ../../core/network.nix
        ../../core/security.nix
        ../../core/sops.nix
        inputs.sops-nix.nixosModules.sops
        ../../interface
      ];
      _module.args = { inherit inputs userState; };

      # Mock secrets
      sops.validateSopsFiles = false;
      systemd.services.tailscale-autoconnect.enable = false;
      # Workaround for CI "modules-shrunk" error
      hardware.enableAllHardware = true;
      boot.kernelPackages = pkgs.linuxPackages_6_6;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    
    # Test if essential tools are in PATH
    machine.succeed("zoxide --version")
    machine.succeed("eza --version")
    machine.succeed("bat --version")
    machine.succeed("rg --version")
    machine.succeed("jq --version")
    machine.succeed("fastfetch --version")
    machine.succeed("btop --version")
    machine.succeed("lazygit --version")
    
    # Test if Zsh is configured correctly for the user
    # Note: we check if the user shell is indeed zsh
    machine.succeed("getent passwd cafaye | grep /zsh")
    
    # Test if interactive zsh has starship hook
    machine.succeed("sudo -u cafaye zsh -i -c 'starship --version'")
    
    # Test Zellij availability
    machine.succeed("zellij --version")
  '';
}
