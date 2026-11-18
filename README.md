# Next.js AWS Production - Guestbook App

Production-ready Next.js application with PostgreSQL guestbook, deployable to AWS EC2 with Docker, Nginx, and SSL.

## Features

- ✅ Next.js 14 with App Router
- ✅ PostgreSQL 17 with persistent volume
- ✅ Guestbook CRUD API
- ✅ Docker multi-stage build
- ✅ Nginx reverse proxy with SSL
- ✅ Automated database backups
- ✅ Health check endpoints
- ✅ Production-ready architecture

## Quick Start (Local)

### Prerequisites
- Docker & Docker Compose
- Node.js 18+

### Setup

```bash
# Clone repository
git clone <your-repo>
cd nextjs-aws-production

# Copy environment file
cp .env.example .env

# Start services
docker compose up -d --build

# Access application
# Next.js: http://localhost:3001
# PostgreSQL: localhost:5434
```

### Test API

```bash
# Health check
curl http://localhost:3001/api/health

# Add guestbook entry
curl -X POST http://localhost:3001/api/guestbook \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","message":"Hello"}'

# Get all entries
curl http://localhost:3001/api/guestbook
```

## AWS EC2 Deployment

### Prerequisites
- AWS Account (Free Tier eligible)
- SSH Key Pair
- Domain name (optional)

### Step-by-Step Guide

See [AWS_EC2_SETUP_GUIDE.md](docs/AWS_EC2_SETUP_GUIDE.md) for detailed instructions.

**Quick Summary:**

1. **Launch EC2 Instance**
   - OS: Debian 13 or Ubuntu 24.04
   - Type: t3.micro (Free Tier)
   - Key Pair: RSA
   - Security Group: 22 (your IP), 80, 443
   - Elastic IP: Allocate and associate

2. **Bootstrap Docker**
   ```bash
   ssh -i key.pem debian@EC2_IP
   wget https://raw.githubusercontent.com/your-repo/main/scripts/bootstrap.sh
   chmod +x bootstrap.sh
   ./bootstrap.sh
   exit
   ssh -i key.pem debian@EC2_IP  # Re-login for docker group
   ```

3. **Deploy Application**
   ```bash
   cd /opt/app
   git clone <your-repo> .
   cp .env.prod.example .env
   nano .env  # Edit DATABASE_PASSWORD
   docker compose -f docker-compose.prod.yml up -d --build
   ```

4. **Setup Nginx**
   ```bash
   sudo apt install nginx certbot python3-certbot-nginx
   sudo cp nginx/nginx.conf /etc/nginx/nginx.conf
   sudo nginx -t
   sudo systemctl restart nginx
   sudo certbot --nginx -d your-domain.com
   ```

5. **Setup Backups**
   ```bash
   chmod +x scripts/backup.sh
   crontab -e
   # Add: 0 2 * * * /opt/app/scripts/backup.sh
   ```

## Project Structure

```
nextjs-aws-production/
├── app/                      # Next.js application
│   ├── app/                 # App Router pages
│   │   ├── api/            # API routes
│   │   │   ├── health/     # Health check
│   │   │   ├── guestbook/  # Guestbook CRUD
│   │   │   └── todos/      # Todo CRUD
│   │   └── page.tsx        # Home page
│   ├── components/         # React components
│   │   └── guestbook.tsx   # Guestbook UI
│   ├── lib/               # Utilities
│   │   └── db.ts          # PostgreSQL connection
│   ├── Dockerfile         # Multi-stage build
│   └── package.json
├── docker-compose.yml      # Local development
├── docker-compose.prod.yml # Production deployment
├── nginx/
│   └── nginx.conf         # Nginx reverse proxy
├── scripts/
│   ├── bootstrap.sh       # EC2 Docker setup
│   ├── backup.sh          # Database backup
│   └── deploy.sh          # Deploy automation
├── docs/
│   └── AWS_EC2_SETUP_GUIDE.md
└── README.md
```

## Architecture

```
Internet
    ↓
Nginx (443) → TLS Termination
    ↓
Next.js (3000) → Docker Network
    ↓
PostgreSQL (5432) → Docker Volume
```

**Security:**
- Port 3000 and 5432 NOT exposed to internet
- Only Nginx on 80/443 accessible
- Database in internal Docker network
- SSH restricted to your IP

## Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/dbname
DATABASE_SSL=false
DB_POOL_MAX=5

# Application
NODE_ENV=production
```

## API Endpoints

- `GET /api/health` - Health check
- `GET /api/guestbook` - Get all entries
- `POST /api/guestbook` - Create entry
- `GET /api/todos` - Get todos
- `POST /api/todos` - Create todo

## Database Schema

```sql
-- Guestbook table
CREATE TABLE guestbook (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Todos table
CREATE TABLE todos (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Monitoring

### Check Container Status
```bash
docker compose -f docker-compose.prod.yml ps
```

### View Logs
```bash
docker compose -f docker-compose.prod.yml logs -f app
docker compose -f docker-compose.prod.yml logs -f db
```

### Health Check
```bash
curl http://localhost/api/health
```

## Troubleshooting

### Container won't start
```bash
docker compose logs app
docker compose logs db
```

### Database connection error
```bash
docker compose exec db pg_isready -U appuser
docker compose exec app env | grep DATABASE_URL
```

### Nginx 502 Bad Gateway
```bash
docker compose ps
sudo nginx -t
```

## Cost Estimation (Free Tier)

- EC2 t3.micro: Free (750 hrs/month, 12 months)
- Elastic IP: Free (when attached to running instance)
- 20 GB gp3: Free (30 GB/month, 12 months)
- Data Transfer: 100 GB/month free

**Total**: Free for first 12 months

## Cleanup

```bash
# Stop containers
docker compose -f docker-compose.prod.yml down

# Delete EC2 resources (via AWS Console)
# - Terminate instance
# - Release Elastic IP
# - Delete Security Group
# - Delete Key Pair
```

## Next Steps

After manual deployment:

1. **Terraform IaC** - Automate infrastructure
2. **GitHub Actions** - CI/CD pipeline
3. **Kubernetes** - Scale to multiple instances

## License

MIT

---

## Project Governance

[![CI](https://github.com/aryafatthurahman4-collab/nextjs-aws-production/actions/workflows/ci.yml/badge.svg)](https://github.com/aryafatthurahman4-collab/nextjs-aws-production/actions/workflows/ci.yml)

[Contributing](CONTRIBUTING.md) | [Security Policy](SECURITY.md) | [Code of Conduct](CODE_OF_CONDUCT.md)