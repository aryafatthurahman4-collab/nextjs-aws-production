# Nextjs-Aws-Production
<sub><span style="opacity: 0.85">Aplikasi Next.js siap produksi di AWS dengan PostgreSQL, Terraform, dan Docker.</span></sub>
<div align="center" style="font-size: 0.9em">
<img src="assets/brand-logo.svg" alt="Arya Fatthurahman" width="130px" />
</div>

[![CI](https://github.com/devarent/nextjs-aws-production/actions/workflows/ci.yml/badge.svg)](https://github.com/devarent/nextjs-aws-production/actions/workflows/ci.yml)

---


<!-- identity-block -->
<div align="center">

# nextjs-aws-production

<sub>Aplikasi Next.js siap produksi di AWS dengan PostgreSQL, Terraform, dan Docker.</sub>

</div>

## At a glance

| Field | Detail |
| --- | --- |
| Repository | nextjs-aws-production |
| Primary language | TypeScript |
| Topics | aws, docker, nextjs, nodejs, postgresql, production, terraform, typescript |
| License | MIT |
| Branch | main |
| Maintainer | [@devarent](https://github.com/devarent) |

## Overview

nextjs-aws-production is a hands-on repository focused on: Aplikasi Next.js siap produksi di AWS dengan PostgreSQL, Terraform, dan Docker.. Primary language: TypeScript. Topics: aws, docker, nextjs, nodejs, postgresql, production, terraform, typescript. The README below documents the project; use the table above for a quick overview.

### Global references

<div align="center">

🇮🇸 Iceland &middot; 🇳🇿 New Zealand &middot; 🇨🇭 Switzerland &middot; 🇸🇮 Slovenia &middot; 🇮🇪 Ireland &middot; 🇦🇹 Austria &middot; 🇵🇹 Portugal &middot; 🇸🇬 Singapore &middot; 🇫🇮 Finland

</div>

---

<!-- dbx-style-kit -->
<div align="center">

<img src="https://img.shields.io/badge/nextjs-aws-production-1f6feb?style=for-the-badge" alt="nextjs-aws-production" />
<img src="https://img.shields.io/badge/LANG%20TypeScript-3178c6?style=for-the-badge" alt="LANG TypeScript" />
<img src="https://img.shields.io/badge/STARS%200-eab308?style=for-the-badge" alt="STARS 0" />
<img src="https://img.shields.io/badge/LICENSE%20MIT-22c55e?style=for-the-badge" alt="LICENSE MIT" />

<br>

<img src="https://img.shields.io/badge/OPEN%20SOURCE-yes-22c55e?style=for-the-badge&logo=github&logoColor=white" alt="OPEN SOURCE" />
<img src="https://img.shields.io/badge/BUILT%20IN%20PUBLIC-true-6366f1?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="BUILT IN PUBLIC" />
<img src="https://img.shields.io/badge/HANDS%20ON%20LABS-52-0ea5e9?style=for-the-badge&logo=docker&logoColor=white" alt="HANDS ON LABS" />
<img src="https://img.shields.io/badge/DOCUMENTED-yes-14b8a6?style=for-the-badge&logo=markdown&logoColor=white" alt="DOCUMENTED" />

<br>

<b>Aplikasi Next.js siap produksi di AWS dengan PostgreSQL, Terraform, dan Docker.</b>

</div>

---
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

[![CI](https://github.com/devarent/nextjs-aws-production/actions/workflows/ci.yml/badge.svg)](https://github.com/devarent/nextjs-aws-production/actions/workflows/ci.yml)

[Contributing](CONTRIBUTING.md) | [Security Policy](SECURITY.md) | [Code of Conduct](CODE_OF_CONDUCT.md)

---

<!-- tech-stack-wall -->
## Tech Stack

<div align="center">

<img src="https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
<img src="https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white" alt="Next.js" />
<img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
<img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform" />
<img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonwebservices&logoColor=white" alt="AWS" />

</div>

<details>
<summary><b>Full Tech Stack Wall</b></summary>
<br>

<div align="center">

<b>Languages</b><br>
<img src="https://img.shields.io/badge/Rust-dea584?style=for-the-badge&logo=rust&logoColor=black" alt="Rust" />
<img src="https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white" alt="Go" />
<img src="https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
<img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black" alt="JavaScript" />
<img src="https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java" />
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
<img src="https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=black" alt="C" />
<img src="https://img.shields.io/badge/C%2B%2B-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++" />
<img src="https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white" alt="Kotlin" />
<img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift" />
<img src="https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white" alt="Ruby" />
<img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP" />
<img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua" />
<img src="https://img.shields.io/badge/Shell-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Shell" />
<br><br>
<b>Frontend &amp; Desktop</b><br>
<img src="https://img.shields.io/badge/Vue-4FC08D?style=for-the-badge&logo=vuedotjs&logoColor=black" alt="Vue" />
<img src="https://img.shields.io/badge/React-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React" />
<img src="https://img.shields.io/badge/Svelte-FF3E00?style=for-the-badge&logo=svelte&logoColor=white" alt="Svelte" />
<img src="https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white" alt="Next.js" />
<img src="https://img.shields.io/badge/Nuxt-00DC82?style=for-the-badge&logo=nuxtdotjs&logoColor=black" alt="Nuxt" />
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/React%20Native-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React Native" />
<img src="https://img.shields.io/badge/Tauri-FFC131?style=for-the-badge&logo=tauri&logoColor=black" alt="Tauri" />
<img src="https://img.shields.io/badge/Electron-47848F?style=for-the-badge&logo=electron&logoColor=white" alt="Electron" />
<img src="https://img.shields.io/badge/Vite-646CFF?style=for-the-badge&logo=vite&logoColor=white" alt="Vite" />
<img src="https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white" alt="HTML5" />
<img src="https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white" alt="CSS3" />
<img src="https://img.shields.io/badge/Sass-CC6699?style=for-the-badge&logo=sass&logoColor=white" alt="Sass" />
<img src="https://img.shields.io/badge/Less-1D365D?style=for-the-badge&logo=less&logoColor=white" alt="Less" />
<img src="https://img.shields.io/badge/Tailwind%20CSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white" alt="Tailwind CSS" />
<img src="https://img.shields.io/badge/Bootstrap-7952B3?style=for-the-badge&logo=bootstrap&logoColor=white" alt="Bootstrap" />
<img src="https://img.shields.io/badge/Three.js-000000?style=for-the-badge&logo=threedotjs&logoColor=white" alt="Three.js" />
<img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="Node.js" />
<img src="https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white" alt="jQuery" />
<br><br>
<b>Database &amp; Storage</b><br>
<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
<img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
<img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
<img src="https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white" alt="SQL Server" />
<img src="https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white" alt="Oracle" />
<img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white" alt="Redis" />
<img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB" />
<img src="https://img.shields.io/badge/DuckDB-FFCB00?style=for-the-badge&logo=duckdb&logoColor=black" alt="DuckDB" />
<img src="https://img.shields.io/badge/ClickHouse-FFCC00?style=for-the-badge&logo=clickhouse&logoColor=black" alt="ClickHouse" />
<img src="https://img.shields.io/badge/Elasticsearch-005571?style=for-the-badge&logo=elasticsearch&logoColor=white" alt="Elasticsearch" />
<img src="https://img.shields.io/badge/Neo4j-008CC1?style=for-the-badge&logo=neo4j&logoColor=white" alt="Neo4j" />
<img src="https://img.shields.io/badge/InfluxDB-22ADF6?style=for-the-badge&logo=influxdb&logoColor=white" alt="InfluxDB" />
<img src="https://img.shields.io/badge/Cassandra-1287B1?style=for-the-badge&logo=apachecassandra&logoColor=white" alt="Cassandra" />
<img src="https://img.shields.io/badge/DynamoDB-4053D6?style=for-the-badge&logo=amazondynamodb&logoColor=white" alt="DynamoDB" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
<img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=black" alt="Supabase" />
<img src="https://img.shields.io/badge/MinIO-C72E49?style=for-the-badge&logo=minio&logoColor=white" alt="MinIO" />
<br><br>
<b>Messaging &amp; Streaming</b><br>
<img src="https://img.shields.io/badge/Kafka-231F20?style=for-the-badge&logo=apachekafka&logoColor=white" alt="Kafka" />
<img src="https://img.shields.io/badge/RabbitMQ-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white" alt="RabbitMQ" />
<img src="https://img.shields.io/badge/RocketMQ-FF6A00?style=for-the-badge&logoColor=white" alt="RocketMQ" />
<img src="https://img.shields.io/badge/Pulsar-188FFF?style=for-the-badge&logo=apachepulsar&logoColor=white" alt="Pulsar" />
<img src="https://img.shields.io/badge/Flink-E6526F?style=for-the-badge&logo=apacheflink&logoColor=white" alt="Flink" />
<br><br>
<b>DevOps &amp; Cloud Native</b><br>
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
<img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" alt="Kubernetes" />
<img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform" />
<img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white" alt="Ansible" />
<img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white" alt="Jenkins" />
<img src="https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions" />
<img src="https://img.shields.io/badge/GitLab%20CI-FC6D26?style=for-the-badge&logo=gitlab&logoColor=white" alt="GitLab CI" />
<img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" alt="Prometheus" />
<img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" alt="Grafana" />
<img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white" alt="Nginx" />
<img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonwebservices&logoColor=white" alt="AWS" />
<img src="https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white" alt="Azure" />
<img src="https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white" alt="Cloudflare" />
<br><br>
<b>Tools &amp; Platforms</b><br>
<img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" alt="Git" />
<img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
<img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS" />
<img src="https://img.shields.io/badge/VS%20Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white" alt="VS Code" />
<img src="https://img.shields.io/badge/Vim-019733?style=for-the-badge&logo=vim&logoColor=white" alt="Vim" />
<img src="https://img.shields.io/badge/Tmux-1BB91F?style=for-the-badge&logoColor=white" alt="Tmux" />
<img src="https://img.shields.io/badge/Homebrew-FAB316?style=for-the-badge&logo=homebrew&logoColor=black" alt="Homebrew" />
<img src="https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=postman&logoColor=white" alt="Postman" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" alt="Figma" />
<img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white" alt="Markdown" />
<img src="https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white" alt="Maven" />
<img src="https://img.shields.io/badge/Gradle-02303A?style=for-the-badge&logo=gradle&logoColor=white" alt="Gradle" />
<img src="https://img.shields.io/badge/CMake-064F8C?style=for-the-badge&logo=cmake&logoColor=white" alt="CMake" />

</div>
</details>

<div align="center">
<sub>Hands-on engineering, built and documented in the open.</sub>
</div>