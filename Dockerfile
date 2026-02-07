FROM nixos/nix:latest

# Enable flakes
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Set up working directory
WORKDIR /app

# Copy the project
COPY . .

# Set up a shell entrypoint
ENTRYPOINT ["nix", "develop"]
