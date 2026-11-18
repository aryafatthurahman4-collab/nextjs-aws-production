#!/bin/bash
# SSL certificate setup script

set -e

echo "=== SSL Certificate Setup ==="

# Check if domain is set
if [ -z "$1" ]; then
    echo "Usage: $0 <domain> [email]"
    echo "Example: $0 example.com admin@example.com"
    exit 1
fi

DOMAIN=$1
EMAIL=${2:-"admin@$DOMAIN"}

echo "Setting up SSL for domain: $DOMAIN"
echo "Email: $EMAIL"

# Stop NGINX container temporarily
echo "Stopping NGINX container..."
docker compose stop nginx

# Get SSL certificate
echo "Getting SSL certificate from Let's Encrypt..."
sudo certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive

# Create SSL directory if it doesn't exist
mkdir -p nginx/ssl

# Copy certificates
echo "Copying certificates..."
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/

# Set permissions
sudo chown -R ubuntu:ubuntu nginx/ssl
sudo chmod 600 nginx/ssl/privkey.pem

# Start NGINX container
echo "Starting NGINX container..."
docker compose start nginx

# Test renewal
echo "Testing certificate renewal..."
sudo certbot renew --dry-run

echo "✓ SSL certificate setup completed!"
echo "Certificate will auto-renew. Check with: sudo certbot certificates"
