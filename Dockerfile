FROM nixos/nix:latest

# Enable flakes and experimental features
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Set up working directory
WORKDIR /app

# Copy the project files
COPY . .

# Pre-fetch dependencies to speed up subsequent runs (optional but good)
RUN nix flake update --extra-experimental-features "nix-command flakes"

# Entrypoint to run the CI checks
ENTRYPOINT ["nix", "flake", "check", "--show-trace"]
