{ pkgs, inputs, ... }:

{
  name = "workload-aliases";
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
          inputs.sops-nix.nixosModules.sops
          ../../interface
        ];
        _module.args = { 
          inherit inputs;
          userState = {
            core = { authorized_keys = []; security = { bootstrap_mode = false; }; };
            interface = { terminal = { shell = "zsh"; multiplexer = "none"; }; };
            languages = { ruby = true; };
            frameworks = { rails = true; };
          };
        };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    
    # Check if Ruby/Rails aliases are present in interactive shell
    # We use zsh -i -c 'alias' to list all aliases
    machine.succeed("sudo -u cafaye zsh -i -c 'alias' | grep 'rs=bundle exec rails server'")
    machine.succeed("sudo -u cafaye zsh -i -c 'alias' | grep 'rc=bundle exec rails console'")
    machine.succeed("sudo -u cafaye zsh -i -c 'alias' | grep 'be=bundle exec'")
  '';
}
