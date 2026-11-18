#!/bin/bash
# Backup PostgreSQL database to local file

BACKUP_DIR="/opt/app/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"

# Create backup directory if not exists
mkdir -p $BACKUP_DIR

echo "=== Starting backup at $(date) ==="

# Backup database
docker compose exec -T db pg_dump -U appuser appdb > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "=== Backup successful: $BACKUP_FILE ==="
    # Show file size
    ls -lh $BACKUP_FILE
else
    echo "=== Backup failed ==="
    exit 1
fi

# Keep only last 7 days of backups
echo "=== Cleaning old backups (keeping last 7 days) ==="
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete

# List remaining backups
echo "=== Current backups ==="
ls -lh $BACKUP_DIR

echo "=== Backup completed ==="
