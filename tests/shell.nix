{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "cafaye-test-env";

  buildInputs = with pkgs; [
    # Core Tools
    bashInteractive
    coreutils
    shellcheck
    git

    # Processing & Logic
    jq
    yq
    gum

    # VM Management (QEMU / Libvirt)
    qemu
    libvirt
    virt-manager

    # Networking / SSH
    openssh
    sshpass
    netcat

    # Testing Utilities
    bats # Bash Automated Testing System
  ];

  shellHook = ''
    echo "🧪 Cafaye OS Test Environment Loaded"
    echo "   - QEMU/KVM: Ready"
    echo "   - BATS: Ready"
    echo "   - Tools: jq, gum, sshpass"
  '';
}
