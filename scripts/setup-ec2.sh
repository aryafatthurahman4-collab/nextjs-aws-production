#!/bin/bash
# Setup script for EC2 instance

set -e

echo "=== EC2 Setup Script ==="

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Git
echo "Installing Git..."
apt-get install -y git

# Create app directory
mkdir -p /opt/app
chown ubuntu:ubuntu /opt/app

# Create swap file for t3.micro
echo "Creating swap file..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Install Certbot
echo "Installing Certbot..."
apt-get install -y certbot python3-certbot-nginx

# Set up automatic security updates
echo "Setting up automatic security updates..."
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

echo "✓ EC2 setup completed successfully!"
echo "Docker, Git, Certbot, and swap are configured."
