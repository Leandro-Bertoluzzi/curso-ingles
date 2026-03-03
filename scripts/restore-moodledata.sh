#!/bin/bash

# English Academy - Moodledata Restore Script

set -e

BACKUP_DIR="backups"
PROJECT_NAME=${PROJECT_NAME:-curso-ingles}

echo "🔄 Moodledata Restore Script"
echo ""

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: Backup directory '$BACKUP_DIR' not found!"
    exit 1
fi

# List available backups
echo "📋 Available moodledata backups:"
echo ""
ls -lh $BACKUP_DIR/moodledata_backup_*.tar.gz 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'

if [ $? -ne 0 ]; then
    echo "❌ No moodledata backups found in '$BACKUP_DIR'!"
    exit 1
fi

echo ""

# Get backup file from argument or prompt user
if [ -z "$1" ]; then
    echo "💡 Usage: $0 <backup_file>"
    echo "   Example: $0 backups/moodledata_backup_20260302_120000.tar.gz"
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

# Extract just the filename for docker volume mount
BACKUP_FILENAME=$(basename "$BACKUP_FILE")

echo ""
echo "⚠️  WARNING: This will replace all moodledata files with the backup!"
echo "   Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo ""
echo "🔄 Stopping Moodle container..."
docker compose stop moodle

echo "🔄 Restoring moodledata..."

# Clear existing data and restore backup
docker run --rm \
    -v curso-andre_moodledata_data:/data \
    -v $(pwd)/$BACKUP_DIR:/backup \
    alpine sh -c "rm -rf /data/* /data/..?* /data/.[!.]* 2>/dev/null; tar -xzf /backup/$BACKUP_FILENAME -C /data"

if [ $? -eq 0 ]; then
    echo "✅ Moodledata restored successfully!"
    echo ""
    echo "🚀 Restarting Moodle container..."
    docker compose start moodle
    echo ""
    echo "💡 Next steps:"
    echo "   1. Wait for Moodle to start: docker compose logs -f moodle"
    echo "   2. Clear Moodle cache: docker compose exec moodle php admin/cli/purge_caches.php"
    echo "   3. Access your site at: http://localhost:8080"
else
    echo "❌ Moodledata restore failed!"
    echo "🚀 Restarting Moodle container anyway..."
    docker compose start moodle
    exit 1
fi
