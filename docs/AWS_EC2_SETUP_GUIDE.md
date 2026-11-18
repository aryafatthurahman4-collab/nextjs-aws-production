# AWS EC2 Production Setup Guide

Aplikasi Next.js Guestbook dengan PostgreSQL di AWS EC2

## Prerequisites

- AWS Account (Free Tier eligible)
- SSH Key Pair
- Domain name (opsional, bisa pakai IP langsung untuk testing)

---

## Langkah 1: Launch EC2 Instance

### 1.1 Login ke AWS Console
Buka: https://console.aws.amazon.com/ec2/

### 1.2 Launch Instance
1. Klik "Launch Instance"
2. **Name**: `nextjs-guestbook`
3. **OS Images**: Debian 13 (ami-xxxx) atau Ubuntu 24.04 LTS
4. **Instance Type**: `t3.micro` (Free Tier)
5. **Key Pair**: Create atau pilih existing key pair (RSA)
6. **Network Settings**:
   - VPC: Default
   - Subnet: Default
   - Auto-assign Public IP: Enable
   - Security Group: Create new
7. **Configure Storage**: 20 GB gp3
8. Klik "Launch Instance"

### 1.3 Allocate Elastic IP
1. EC2 → Elastic IPs → Allocate Elastic IP address
2. Associate dengan instance yang baru dibuat
3. Catat IP Address (misal: `16.78.1.204`)

---

## Langkah 2: Security Group Configuration

### 2.1 Security Group Rules
Edit security group yang terhubung ke instance:

**Inbound Rules:**
- **SSH (22)**: Source = IP kamu (e.g., `203.0.113.0/32`)
- **HTTP (80)**: Source = `0.0.0.0/0`
- **HTTPS (443)**: Source = `0.0.0.0/0`

**JANGAN buka:**
- Port 3000 (Next.js)
- Port 5432 (PostgreSQL)
- Port 8090 (Adminer)

---

## Langkah 3: SSH ke EC2

```bash
# Di lokal Windows (WSL/CMD/Powershell)
ssh -i /path/to/your-key.pem debian@16.78.1.204

# Atau jika menggunakan WSL
ssh -i /mnt/c/path/to/your-key.pem debian@16.78.1.204
```

---

## Langkah 4: Bootstrap Docker

Copy dan paste script ini di EC2:

```bash
#!/bin/bash
set -e

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing dependencies ==="
sudo apt install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    lsb-release

echo "=== Installing Docker ==="
# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Enable Docker without sudo ==="
sudo usermod -aG docker $USER

echo "=== Creating swap (2GB) ==="
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "=== Setup project directory ==="
sudo mkdir -p /opt/app
sudo chown $USER:$USER /opt/app

echo "=== Setup firewall ==="
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "=== Docker installed successfully ==="
docker --version
docker compose version
```

Simpan sebagai `bootstrap.sh`, lalu:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

**Re-login SSH** agar user group docker aktif:
```bash
exit
ssh -i /path/to/key.pem debian@16.78.1.204
```

---

## Langkah 5: Clone & Setup Project

```bash
cd /opt/app
git clone <your-repo-url> .
# Atau copy file manual menggunakan scp

# Set permissions
chmod +x scripts/*.sh
```

---

## Langkah 6: Deploy dengan Docker Compose

```bash
# Copy .env.example ke .env
cp .env.example .env

# Edit .env jika perlu
nano .env

# Build dan start
docker compose up -d --build

# Check status
docker compose ps
docker compose logs -f
```

---

## Langkah 7: Setup Nginx Reverse Proxy

### 7.1 Install Nginx
```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

### 7.2 Copy Nginx Config
```bash
sudo cp nginx/nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
```

### 7.3 Setup SSL dengan Let's Encrypt (jika punya domain)
```bash
sudo certbot --nginx -d your-domain.com
```

### 7.4 Test
```bash
curl http://localhost
curl https://your-domain.com
```

---

## Langkah 8: Setup Backup Database

### 8.1 Buat backup script
```bash
nano /opt/app/scripts/backup.sh
```

Isi:
```bash
#!/bin/bash
BACKUP_DIR="/opt/app/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

docker compose exec -T db pg_dump -U appuser appdb > $BACKUP_DIR/backup_$DATE.sql

# Keep last 7 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

### 8.2 Setup cron job
```bash
crontab -e
```

Tambah:
```
0 2 * * * /opt/app/scripts/backup.sh
```

---

## Langkah 9: Monitoring & Health Check

### 9.1 Check Health
```bash
curl http://localhost:3001/api/health
```

### 9.2 Check Logs
```bash
docker compose logs -f app
docker compose logs -f db
```

### 9.3 Auto-restart policy
Docker compose sudah mengatur `restart: unless-stopped`

---

## Troubleshooting

### Container tidak start
```bash
docker compose logs app
docker compose logs db
```

### Database connection error
```bash
# Check database is up
docker compose exec db pg_isready -U appuser

# Check DATABASE_URL
docker compose exec app env | grep DATABASE_URL
```

### Nginx 502 Bad Gateway
```bash
# Check app container running
docker compose ps

# Check nginx config
sudo nginx -t
```

### Port conflict
```bash
sudo netstat -tulpn | grep LISTEN
```

---

## Biaya Estimasi (Free Tier)

- **EC2 t3.micro**: Gratis (750 jam/bulan, 12 bulan pertama)
- **Elastic IP**: Gratis jika attached ke running instance
- **20 GB gp3**: Gratis (30 GB/bulan, 12 bulan pertama)
- **Data Transfer**: 100 GB/bulan gratis

**Total**: Gratis untuk 12 bulan pertama (jika pakai Free Tier resources)

---

## Cleanup (Hapus Resources)

```bash
# Stop docker
docker compose down

# Delete EC2 instance di AWS Console
# Release Elastic IP
# Delete Security Group
# Delete Key Pair
```

---

## Next Steps

Setelah manual setup berhasil, Anda bisa:
1. Setup Terraform untuk IaC
2. Setup GitHub Actions untuk CI/CD
3. Setup Kubernetes untuk scaling
