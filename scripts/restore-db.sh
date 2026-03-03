#!/bin/bash

# English Academy - Database Restore Script

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

BACKUP_DIR="backups"
PROJECT_NAME=${PROJECT_NAME:-curso-ingles}

echo "🔄 Database Restore Script"
echo ""

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: Backup directory '$BACKUP_DIR' not found!"
    exit 1
fi

# List available backups
echo "📋 Available database backups:"
echo ""
ls -lh $BACKUP_DIR/db_backup_*.sql 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'

if [ $? -ne 0 ]; then
    echo "❌ No database backups found in '$BACKUP_DIR'!"
    exit 1
fi

echo ""

# Get backup file from argument or prompt user
if [ -z "$1" ]; then
    echo "💡 Usage: $0 <backup_file>"
    echo "   Example: $0 backups/db_backup_20260302_120000.sql"
    echo ""
    read -p "Enter backup file path: " BACKUP_FILE
else
    BACKUP_FILE="$1"
fi

# Validate backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file '$BACKUP_FILE' not found!"
    exit 1
fi

echo ""
echo "⚠️  WARNING: This will replace the current database with the backup!"
echo "   Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo ""
echo "🔄 Restoring database..."

# Drop existing database and recreate
docker run --rm --network ${PROJECT_NAME}_moodle-network \
    mariadb:11.2 \
    mariadb -h db -u${MYSQL_USER} -p${MYSQL_PASSWORD} \
    -e "DROP DATABASE IF EXISTS ${MYSQL_DATABASE}; CREATE DATABASE ${MYSQL_DATABASE};" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ Failed to recreate database"
    exit 1
fi

# Restore backup
docker run --rm --network ${PROJECT_NAME}_moodle-network -i \
    -v $(pwd):/backup \
    mariadb:11.2 \
    mariadb -h db -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} \
    < "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Database restored successfully!"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Clear Moodle cache: docker compose exec moodle php admin/cli/purge_caches.php"
    echo "   2. Access your site at: http://localhost:8080"
else
    echo "❌ Database restore failed!"
    exit 1
fi
