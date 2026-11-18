#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create app directory
mkdir -p /opt/app
chown ubuntu:ubuntu /opt/app

# Create swap file for t3.micro (1GB RAM)
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Install Git
apt-get install -y git

# Create directories for SSL certificates
mkdir -p /opt/app/nginx/ssl
mkdir -p /opt/app/nginx/conf.d
chown -R ubuntu:ubuntu /opt/app

# Install Certbot for Let's Encrypt
apt-get install -y certbot python3-certbot-nginx

# Set up automatic security updates
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

# Create a simple health check script
cat > /opt/app/health-check.sh << 'EOF'
#!/bin/bash
curl -f http://localhost:3000/api/health || exit 1
EOF
chmod +x /opt/app/health-check.sh
chown ubuntu:ubuntu /opt/app/health-check.sh

# Log completion
logger "User data script completed successfully"
