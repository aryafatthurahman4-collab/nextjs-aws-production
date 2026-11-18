# Next.js AWS Production - Project Summary

## Overview

This is a complete production-grade DevOps workbench for deploying Next.js applications on AWS EC2 with Docker, NGINX, SSL, and CI/CD automation.

## Project Structure

```
nextjs-aws-production/
├── app/                          # Next.js application
│   ├── app/                      # Next.js app directory
│   │   ├── api/                  # API routes
│   │   │   ├── todos/            # Todo CRUD operations
│   │   │   └── health/           # Health check endpoint
│   │   ├── layout.tsx            # Root layout
│   │   ├── page.tsx              # Home page
│   │   └── globals.css           # Global styles
│   ├── components/               # React components
│   │   └── todo-app.tsx          # Todo application component
│   ├── lib/                      # Utility libraries
│   │   └── db.ts                 # Database connection
│   ├── public/                   # Static assets
│   ├── Dockerfile                # Multi-stage Docker build
│   ├── package.json              # Dependencies
│   ├── tsconfig.json             # TypeScript config
│   ├── next.config.ts            # Next.js config
│   └── postcss.config.mjs        # PostCSS config
│
├── docker/                       # Docker configurations
│   └── (docker-compose.yml in root)
│
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Main Terraform config
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output values
│   ├── vpc.tf                    # VPC configuration
│   ├── security-groups.tf        # Security groups
│   ├── ec2.tf                    # EC2 instance
│   ├── rds.tf                    # RDS database
│   ├── user-data.sh              # EC2 bootstrap script
│   ├── terraform.tfvars.example  # Example variables
│   └── .terraform/               # Terraform state (gitignored)
│
├── kubernetes/                   # Kubernetes manifests
│   ├── deployment.yaml           # Deployment, Service, Ingress
│   └── (other manifests)
│
├── nginx/                        # NGINX configuration
│   ├── nginx.conf                # Main NGINX config
│   └── ssl/                      # SSL certificates (generated)
│
├── scripts/                      # Deployment scripts
│   ├── deploy.sh                 # Deployment script
│   ├── setup-ec2.sh              # EC2 setup script
│   ├── setup-ssl.sh              # SSL setup script
│   └── setup-db.sh               # Database setup script
│
├── .github/workflows/            # CI/CD pipelines
│   └── deploy.yml                # GitHub Actions workflow
│
├── docs/                         # Documentation
│   └── DEPLOYMENT.md             # Detailed deployment guide
│
├── docker-compose.yml            # Docker Compose configuration
├── .env.example                  # Environment variables example
├── .gitignore                    # Git ignore rules
└── README.md                     # Project documentation
```

## Key Features

### 1. Next.js Application
- **Next.js 15** with standalone output
- **React 19** with TypeScript
- **Tailwind CSS 4** for styling
- **Todo CRUD API** with PostgreSQL
- **Health check endpoint**
- **Responsive design** with dark mode support

### 2. Docker Configuration
- **Multi-stage build** for optimized image size
- **Alpine Linux** base for smaller images
- **Non-root user** for security
- **Health checks** for all services
- **Docker Compose** for local development

### 3. Infrastructure (Terraform)
- **VPC** with public and private subnets
- **EC2 t3.micro** instance (free tier eligible)
- **RDS PostgreSQL** (optional)
- **Security groups** with proper rules
- **Elastic IP** for static IP
- **2GB SWAP** for memory protection
- **Automatic security updates**

### 4. NGINX Configuration
- **Reverse proxy** to Next.js app
- **SSL/TLS termination** with Let's Encrypt
- **Rate limiting** (30 req/s for API, 50 req/s general)
- **Gzip compression**
- **Security headers**
- **WebSocket support**
- **Static file caching**

### 5. CI/CD Pipeline
- **GitHub Actions** workflow
- **Automated testing** with build verification
- **Docker image** build and push to ECR
- **Auto-deployment** to EC2 or ECS
- **Health checks** after deployment
- **Rollback capability**

### 6. Database Options
- **Docker PostgreSQL** (default, free)
- **AWS RDS PostgreSQL** (managed, ~$15-20/month)
- **Automatic schema creation**
- **Connection pooling**
- **SSL support** for RDS

### 7. Kubernetes (Optional)
- **Deployment manifests** for K8s
- **Service and Ingress** configuration
- **Health probes**
- **Resource limits**
- **TLS support** with cert-manager

## Quick Start

### Local Development

```bash
# Navigate to app directory
cd app

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your database credentials

# Run development server
npm run dev
```

### Docker Compose (Local)

```bash
# From project root
cp .env.example .env
# Edit .env with your configuration

docker compose up -d
```

### AWS EC2 Deployment

```bash
# 1. Configure Terraform
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings

# 2. Deploy infrastructure
terraform init
terraform plan
terraform apply

# 3. Get connection details
terraform output

# 4. SSH into EC2 and deploy
ssh -i <key>.pem ubuntu@<public-ip>
cd /opt/app
git clone <your-repo>
cp .env.example .env
# Edit .env
docker compose up -d

# 5. Set up SSL
sudo ./scripts/setup-ssl.sh your-domain.com admin@your-domain.com
```

## Cost Breakdown

### Free Tier (First 12 Months)
- **EC2 t3.micro**: 750 hours/month free
- **RDS db.t3.micro**: 750 hours/month free
- **20GB EBS storage**: Free
- **Total**: $0/month

### Production (After Free Tier)
- **EC2 t3.micro**: ~$8-10/month
- **RDS db.t3.micro**: ~$15-20/month
- **EBS storage**: ~$2-3/month
- **Data transfer**: ~$1-5/month
- **Total**: ~$25-40/month

## Security Features

✅ **SSL/TLS encryption** with Let's Encrypt  
✅ **Rate limiting** to prevent DDoS  
✅ **Security headers** (XSS, CSRF protection)  
✅ **Non-root Docker user**  
✅ **Encrypted storage** (EBS, RDS)  
✅ **Private subnets** for database  
✅ **Security groups** with minimal access  
✅ **Automatic security updates**  
✅ **Secrets management** via environment variables  

## Monitoring & Maintenance

### Health Checks
- Application: `/api/health`
- Database: Automatic connection check
- Docker: Container health checks
- NGINX: Configuration validation

### Logs
```bash
# Application logs
docker compose logs -f app

# NGINX logs
docker compose logs -f nginx

# Database logs
docker compose logs -f db
```

### Backup Strategy
```bash
# Database backup
docker compose exec db pg_dump -U appuser appdb > backup.sql

# Application backup
cp .env .env.backup
```

## Troubleshooting

### Common Issues

**502 Bad Gateway**
```bash
docker compose ps
docker compose logs app
docker compose restart
```

**Database Connection Issues**
```bash
docker compose exec app node -e "require('pg').Client({connectionString: process.env.DATABASE_URL}).connect().then(()=>console.log('Connected')).catch(e=>console.error(e))"
```

**SSL Certificate Issues**
```bash
sudo certbot certificates
sudo certbot renew
docker compose restart nginx
```

**High Memory Usage**
```bash
free -h
docker stats
docker compose restart
```

## Scaling Options

### Horizontal Scaling
- Multiple EC2 instances behind ALB
- Auto Scaling Groups
- RDS read replicas

### Vertical Scaling
- Upgrade EC2 instance type
- Increase RDS instance class
- Adjust Docker resource limits

### Kubernetes
- Deploy to EKS (Elastic Kubernetes Service)
- Use manifests in `kubernetes/` directory
- Auto-scaling with HPA

## Documentation

- **README.md** - Project overview and quick start
- **docs/DEPLOYMENT.md** - Detailed deployment guide
- **terraform/README.md** - Terraform-specific documentation
- **scripts/** - Automation scripts

## Support

- **GitHub Issues**: Report bugs and request features
- **AWS Documentation**: AWS service documentation
- **Next.js Documentation**: Next.js framework docs
- **Docker Documentation**: Docker and Docker Compose docs

## License

MIT License - See LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Acknowledgments

- Next.js team for the amazing framework
- AWS for cloud infrastructure
- Docker for containerization
- Terraform for Infrastructure as Code
- The open-source community
