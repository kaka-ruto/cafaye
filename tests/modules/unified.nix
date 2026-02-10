{ pkgs, inputs, userState, ... }:

let
  # For modules test, enable all services to test them together
  testState = userState // {
    services = {
      postgresql = true;
      redis = true;
    };
    # Force enable all languages for testing
    languages = {
      rust = true;
      go = true;
      nodejs = true;
      python = true;
      ruby = true;
    };
  };
in

# Unified Modules Test - Tests languages, services, editors, frameworks in ONE VM boot
# This replaces: modules-languages, modules-services, modules-editors, modules-editors-distributions, modules-frameworks
{
  name = "modules-unified";
  nodes = {
    machine = { ... }:
      {
        imports = [
          ../../core/boot.nix
          ../../core/hardware.nix
          ../../core/network.nix
          ../../core/security
          ../../core/sops.nix
          ../../core/user.nix
          inputs.sops-nix.nixosModules.sops
          ../../modules
          ../../interface
        ];
        _module.args = { inherit inputs; userState = testState; };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # === MODULES-LANGUAGES TESTS ===
    # Test all languages are available
    machine.succeed("rustup --version")
    machine.succeed("go version")
    machine.succeed("node --version")
    machine.succeed("npm --version")
    machine.succeed("python3 --version")
    machine.succeed("pip --version")
    machine.succeed("ruby --version")
    machine.succeed("bundle --version")

    # === MODULES-SERVICES TESTS ===
    # Test PostgreSQL
    machine.wait_for_unit("postgresql.service")
    machine.succeed("sudo -u cafaye psql -c 'select 1' cafaye")
    
    # Test Redis
    machine.wait_for_unit("redis-default.service")
    machine.succeed("redis-cli ping | grep PONG")

    # === MODULES-EDITORS TESTS ===
    # Test if editors are installed (only if enabled in testState)
    ${pkgs.lib.optionalString (testState.editors.neovim or false) ''
      machine.succeed("nvim --version")
    ''}
    
    ${pkgs.lib.optionalString (testState.editors.helix or false) ''
      machine.succeed("hx --version")
    ''}

    # === INTERFACE-TERMINAL TESTS ===
    # Test if essential tools are in PATH
    machine.succeed("zoxide --version")
    machine.succeed("eza --version")
    machine.succeed("bat --version")
    machine.succeed("rg --version")
    machine.succeed("jq --version")
    machine.succeed("fastfetch --version")
    machine.succeed("btop --version")
    machine.succeed("lazygit --version")
    
    # Test Zsh configuration
    machine.succeed("getent passwd cafaye | grep /zsh")
    
    # Test Zellij availability
    machine.succeed("zellij --version")

    # === MODULES-FRAMEWORKS TESTS ===
    # Test framework tools are available (only if enabled in testState)
    ${pkgs.lib.optionalString (testState.frameworks.rails or false) ''
      machine.succeed("which rails || gem list rails")
    ''}
    
    ${pkgs.lib.optionalString (testState.frameworks.django or false) ''
      machine.succeed("which django-admin || pip list | grep -i django")
    ''}
    
    ${pkgs.lib.optionalString (testState.frameworks.nextjs or false) ''
      machine.succeed("npx --version")
    ''}
  '';
}
