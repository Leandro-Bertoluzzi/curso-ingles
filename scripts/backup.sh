#!/bin/bash

# English Academy - Backup Script

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROJECT_NAME=${PROJECT_NAME:-curso-ingles}

echo "💾 Creating backup..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
echo "📦 Backing up database..."
docker run --rm --network ${PROJECT_NAME}_moodle-network \
    mariadb:11.2 \
    mariadb-dump -h db -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} \
    > "$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

if [ $? -eq 0 ] && [ -s "$BACKUP_DIR/db_backup_$TIMESTAMP.sql" ]; then
    echo "   ✅ Database backup successful"
else
    echo "   ❌ Database backup failed"
    rm -f "$BACKUP_DIR/db_backup_$TIMESTAMP.sql"
    exit 1
fi

# Backup moodledata volume
echo "📦 Backing up moodledata volume..."
docker run --rm \
    -v ${PROJECT_NAME}_moodledata_data:/data \
    -v $(pwd)/$BACKUP_DIR:/backup \
    alpine tar -czf /backup/moodledata_backup_$TIMESTAMP.tar.gz -C /data .

if [ $? -eq 0 ] && [ -f "$BACKUP_DIR/moodledata_backup_$TIMESTAMP.tar.gz" ]; then
    echo "   ✅ Moodledata backup successful"
else
    echo "   ❌ Moodledata backup failed"
    exit 1
fi

echo ""
echo "✅ Backup completed successfully!"
echo "📁 Files saved in $BACKUP_DIR/"
echo "   - db_backup_$TIMESTAMP.sql"
echo "   - moodledata_backup_$TIMESTAMP.tar.gz"
echo ""
echo "💡 To restore:"
echo "   Database: ./scripts/restore-db.sh $BACKUP_DIR/db_backup_$TIMESTAMP.sql"
echo "   Moodledata: ./scripts/restore-moodledata.sh $BACKUP_DIR/moodledata_backup_$TIMESTAMP.tar.gz"
