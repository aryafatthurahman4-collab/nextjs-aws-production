# Deployment Guide

This guide provides step-by-step instructions for deploying the Next.js application to AWS EC2.

## Prerequisites

Before you begin, ensure you have:

- AWS account with EC2 access
- AWS CLI installed and configured
- Terraform installed (v1.0+)
- SSH key pair for EC2 access
- Domain name (optional but recommended)
- Git repository access

## Step 1: Prepare Your Environment

### 1.1 Clone the Repository

```bash
cd nextjs-aws-production
```

### 1.2 Install Dependencies (Local Development)

```bash
cd app
npm install
```

### 1.3 Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```bash
# Domain Configuration
DOMAIN=your-domain.com
NEXT_PUBLIC_SITE_URL=https://your-domain.com

# Database Configuration
DATABASE_URL=postgresql://user:password@host:5432/dbname
DATABASE_SSL=true

# Application Configuration
NODE_ENV=production
APP_VERSION=1.0.0
```

## Step 2: Deploy Infrastructure with Terraform

### 2.1 Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region = "ap-southeast-3"
project_name = "nextjs-aws-production"
environment = "prod"
instance_type = "t3.micro"
key_name = "your-key-pair-name"  # or leave empty to create new
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."  # your public key

domain_name = "your-domain.com"
enable_rds = true
rds_master_password = "your-secure-password"
rds_database_name = "appdb"
rds_master_username = "appuser"
```

### 2.2 Initialize Terraform

```bash
terraform init
```

### 2.3 Plan the Deployment

```bash
terraform plan
```

Review the plan to ensure everything looks correct.

### 2.4 Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 2.5 Get Deployment Outputs

```bash
terraform output
```

Note the following outputs:

- `public_ip` - Your EC2 instance public IP
- `app_url` - Your application URL
- `rds_endpoint` - RDS database endpoint (if enabled)
- `rds_connection_string` - Database connection string (if enabled)

## Step 3: Deploy Application to EC2

### 3.1 SSH into EC2 Instance

```bash
ssh -i <your-key>.pem ubuntu@<public-ip>
```

### 3.2 Clone Repository

```bash
cd /opt/app
git clone <your-repo-url> .
```

### 3.3 Configure Environment

```bash
cp .env.example .env
nano .env  # Edit with your configuration
```

### 3.4 Deploy with Docker Compose

```bash
# Pull latest images
docker compose pull

# Start services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 3.5 Verify Deployment

```bash
# Check health endpoint
curl http://localhost:3000/api/health

# Check from outside
curl http://<public-ip>/api/health
```

## Step 4: Configure SSL (Let's Encrypt)

### 4.1 Install Certbot

Certbot should already be installed via user-data script. If not:

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### 4.2 Obtain SSL Certificate

```bash
# Stop NGINX temporarily
cd /opt/app
docker compose stop nginx

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates to NGINX directory
sudo mkdir -p nginx/ssl
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/

# Set permissions
sudo chown -R ubuntu:ubuntu nginx/ssl
sudo chmod 600 nginx/ssl/privkey.pem

# Start NGINX
docker compose start nginx
```

### 4.3 Test SSL

```bash
curl -I https://your-domain.com
```

### 4.4 Set Up Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Set up cron job for auto-renewal
sudo crontab -e
# Add this line:
# 0 12 * * * /usr/bin/certbot renew --quiet --deploy-hook "cd /opt/app && docker compose restart nginx"
```

## Step 5: Configure DNS (Route 53)

### 5.1 Create Hosted Zone (if needed)

```bash
aws route53 create-hosted-zone --name your-domain.com --caller-reference $(date +%s)
```

### 5.2 Update Nameservers

Update your domain registrar with the nameservers from Route 53.

### 5.3 Create A Record

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "your-domain.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "<public-ip>"}]
      }
    }]
  }'
```

## Step 6: Set Up CI/CD

### 6.1 Configure GitHub Secrets

Add these secrets to your GitHub repository:

1. Go to Settings → Secrets and variables → Actions
2. Add the following secrets:

- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- `EC2_HOST` - Your EC2 public IP or domain
- `EC2_USERNAME` - `ubuntu`
- `EC2_SSH_KEY` - Your private SSH key

### 6.2 Push to Trigger Deployment

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

The GitHub Actions workflow will automatically:

1. Build and test the application
2. Build Docker image
3. Push to Amazon ECR
4. Deploy to EC2

## Step 7: Monitoring and Maintenance

### 7.1 Set Up CloudWatch Monitoring

```bash
# Install CloudWatch agent on EC2
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# Configure agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-linux -s
```

### 7.2 Set Up Log Rotation

```bash
# Configure Docker log rotation
sudo nano /etc/docker/daemon.json
```

Add:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker:

```bash
sudo systemctl restart docker
```

### 7.3 Regular Maintenance

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker compose pull
docker compose up -d

# Clean up Docker resources
docker system prune -a
```

## Troubleshooting

### Application Not Loading

```bash
# Check container status
docker compose ps

# Check logs
docker compose logs -f app

# Restart services
docker compose restart
```

### Database Connection Issues

```bash
# Test database connection
docker compose exec app node -e "require('pg').Client({connectionString: process.env.DATABASE_URL}).connect().then(()=>console.log('Connected')).catch(e=>console.error(e))"

# Check database logs
docker compose logs db
```

### SSL Certificate Issues

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Restart NGINX
docker compose restart nginx
```

### High Memory Usage

```bash
# Check swap usage
free -h

# Check Docker stats
docker stats

# Restart containers if needed
docker compose restart
```

## Scaling

### Horizontal Scaling

1. Create additional EC2 instances
2. Set up Application Load Balancer
3. Configure Auto Scaling Group
4. Update DNS to point to ALB

### Vertical Scaling

1. Stop EC2 instance
2. Change instance type in AWS Console
3. Start instance

### Database Scaling

1. Upgrade RDS instance class
2. Enable Multi-AZ for high availability
3. Enable storage autoscaling

## Backup and Recovery

### Database Backup

```bash
# Manual backup
docker compose exec db pg_dump -U appuser appdb > backup.sql

# Automated backup (cron)
0 2 * * * cd /opt/app && docker compose exec db pg_dump -U appuser appdb > /backups/backup-$(date +%Y%m%d).sql
```

### Application Backup

```bash
# Backup .env file
cp .env .env.backup

# Backup Docker volumes
docker run --rm -v app_postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data.tar.gz /data
```

## Security Checklist

- [ ] SSL/TLS enabled
- [ ] Security groups restricted
- [ ] Database in private subnet
- [ ] Secrets not committed to git
- [ ] Regular security updates
- [ ] Backup strategy implemented
- [ ] Monitoring and alerts configured
- [ ] Access logs reviewed
- [ ] Failed login attempts monitored

## Next Steps

- Set up monitoring dashboards
- Configure auto-scaling
- Implement CI/CD for database migrations
- Set up staging environment
- Configure disaster recovery
- Implement WAF (Web Application Firewall)
