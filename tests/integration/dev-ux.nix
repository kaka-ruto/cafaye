{ pkgs, inputs, userState, ... }:

{
  name = "integration-dev-ux";
  nodes = {
    machine = { ... }: {
      imports = [ 
        ../../core/boot.nix
        ../../core/hardware.nix
        ../../core/network.nix
        ../../core/security
        ../../core/sops.nix
        ../../core/user.nix
        inputs.sops-nix.nixosModules.sops
        ../../modules
        ../../cli
      ];
      _module.args = { 
        inherit inputs; 
        userState = userState // { 
          frameworks = { rails = true; }; 
          services = { postgresql = true; redis = true; };
          languages = { ruby = true; nodejs = true; };
        }; 
      };

      sops.validateSopsFiles = false;
      systemd.services.tailscale-autoconnect.enable = false;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    
    # 1. Test 'caf' command presence
    machine.succeed("caf --version")
    
    # 2. Test 'mise' presence and functionality
    # mise needs to be in the path for the user 'cafaye'
    machine.succeed("sudo -u cafaye bash -c 'mise --version'")
    
    # 3. Test 'caf-rails-setup' (our new premium tool)
    machine.succeed("sudo -u cafaye bash -c 'cd ~ && caf-rails-setup my-new-app'")
    
    # 4. Verify project configuration
    machine.succeed("test -f /home/cafaye/my-new-app/config/database.yml")
    machine.succeed("grep 'username: cafaye' /home/cafaye/my-new-app/config/database.yml")
    
    # 5. Test 'caf-system-doctor'
    machine.succeed("caf-system-doctor | grep '✓ Running' | grep 'PostgreSQL'")
    machine.succeed("caf-system-doctor | grep '✓ Running' | grep 'Redis'")
  '';
}
