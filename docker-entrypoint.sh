#!/bin/bash
set -e

# Check if Moodle is already installed in the volume
if [ ! -f /var/www/html/index.php ]; then
    echo "📥 Moodle not found in /var/www/html, copying from /tmp/moodle-install..."
    
    # Copy Moodle files from temporary location to mounted volume
    if [ -d /tmp/moodle-install ]; then
        cp -r /tmp/moodle-install/* /var/www/html/
        echo "✅ Moodle files copied successfully"
    else
        echo "❌ ERROR: Moodle installation files not found!"
        exit 1
    fi
fi

# Set correct permissions
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/moodledata
chmod -R 755 /var/www/html

echo "🚀 Starting Apache in background..."
# Start Apache in background
apache2-foreground &
APACHE_PID=$!

# Wait for Apache to start
sleep 5

# Check if Moodle needs to be configured
if [ ! -f /var/www/html/config.php ]; then
    echo "⚙️  Configuring Moodle automatically..."
    
    # Wait for database to be ready
    echo "⏳ Waiting for database to be ready..."
    until mysql -h"${MOODLE_DB_HOST:-db}" -u"${MOODLE_DB_USER}" -p"${MOODLE_DB_PASS}" -e "SELECT 1" "${MOODLE_DB_NAME}" &>/dev/null; do
        echo "   Database not ready, waiting..."
        sleep 3
    done
    echo "✅ Database is ready!"
    
    # Run Moodle CLI installation
    echo "📦 Installing Moodle..."
    php /var/www/html/admin/cli/install.php \
        --lang="${MOODLE_LANG:-en}" \
        --wwwroot="http://${MOODLE_WEB_HOST:-localhost:8080}" \
        --dataroot="/var/www/moodledata" \
        --dbtype="mariadb" \
        --dbhost="${MOODLE_DB_HOST:-db}" \
        --dbname="${MOODLE_DB_NAME}" \
        --dbuser="${MOODLE_DB_USER}" \
        --dbpass="${MOODLE_DB_PASS}" \
        --fullname="${MOODLE_SITE_FULLNAME:-Moodle Site}" \
        --shortname="${MOODLE_SITE_SHORTNAME:-Moodle}" \
        --adminuser="${MOODLE_ADMIN_USER:-admin}" \
        --adminpass="${MOODLE_ADMIN_PASS:-Admin123!}" \
        --adminemail="${MOODLE_ADMIN_EMAIL:-admin@example.com}" \
        --non-interactive \
        --agree-license
    
    if [ $? -eq 0 ]; then
        # Fix permissions after installation
        echo "🔧 Fixing permissions..."
        chown -R www-data:www-data /var/www/html
        chmod -R 755 /var/www/html
        chmod 644 /var/www/html/config.php
        
        echo ""
        echo "✅ Moodle installed and configured successfully!"
        echo ""
        echo "📱 Access your Moodle site at: http://${MOODLE_WEB_HOST:-localhost:8080}"
        echo "👤 Admin credentials:"
        echo "   Username: ${MOODLE_ADMIN_USER:-admin}"
        echo "   Password: ${MOODLE_ADMIN_PASS:-Admin123!}"
        echo ""
    else
        echo "❌ ERROR: Moodle installation failed!"
        kill $APACHE_PID
        exit 1
    fi
else
    echo "✅ Moodle is already configured"
fi

# Wait for Apache process
wait $APACHE_PID
