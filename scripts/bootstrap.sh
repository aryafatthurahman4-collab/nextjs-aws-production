#!/bin/bash
set -e

echo "=== Bootstrap Docker on EC2 ==="
echo "This script will install Docker, Compose, and setup the environment"

# Update system
echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "=== Installing dependencies ==="
sudo apt install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw

# Add Docker's official GPG key
echo "=== Installing Docker ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker without sudo
echo "=== Enable Docker without sudo ==="
sudo usermod -aG docker $USER

# Create swap (2GB)
echo "=== Creating swap (2GB) ==="
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Setup project directory
echo "=== Setup project directory ==="
sudo mkdir -p /opt/app
sudo chown $USER:$USER /opt/app

# Setup firewall
echo "=== Setup firewall ==="
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "=== Docker installed successfully ==="
docker --version
docker compose version

echo "=== Please logout and login again for docker group to take effect ==="
echo "Run: exit"
echo "Then SSH back into the instance"
