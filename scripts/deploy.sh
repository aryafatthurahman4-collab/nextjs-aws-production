#!/bin/bash
# Deploy script for AWS EC2

set -e

# Configuration
EC2_USER="debian"
EC2_IP="YOUR_EC2_IP_HERE"
KEY_PATH="/path/to/your-key.pem"
PROJECT_DIR="/opt/app"

echo "=== Deploy to EC2 ==="
echo "EC2 IP: $EC2_IP"
echo "Project directory: $PROJECT_DIR"

# Check if required variables are set
if [ "$EC2_IP" = "YOUR_EC2_IP_HERE" ]; then
    echo "ERROR: Please update EC2_IP in this script"
    exit 1
fi

if [ ! -f "$KEY_PATH" ]; then
    echo "ERROR: Key file not found at $KEY_PATH"
    exit 1
fi

# Copy files to EC2
echo "=== Copying files to EC2 ==="
rsync -avz -e "ssh -i $KEY_PATH" \
    --exclude node_modules \
    --exclude .next \
    --exclude .git \
    ./ $EC2_USER@$EC2_IP:$PROJECT_DIR/

# SSH to EC2 and deploy
echo "=== Deploying on EC2 ==="
ssh -i $KEY_PATH $EC2_USER@$EC2_IP << 'ENDSSH'
cd /opt/app

# Stop existing containers
docker compose -f docker-compose.prod.yml down

# Copy environment file
if [ ! -f .env ]; then
    cp .env.prod.example .env
    echo "Please edit .env with your production values"
    exit 1
fi

# Build and start
docker compose -f docker-compose.prod.yml up -d --build

# Wait for health check
echo "Waiting for application to be healthy..."
sleep 30

# Check status
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs app
ENDSSH

echo "=== Deployment complete ==="
echo "Access your app at: http://$EC2_IP"
