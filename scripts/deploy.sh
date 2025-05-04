#!/bin/bash

# Log start of deployment
echo "Starting TN Ad Link deployment process..."

# Wait for database connection
echo "Checking database connection..."
php /var/www/html/scripts/wait-for-db.php
if [ $? -ne 0 ]; then
    echo "Database connection failed. Exiting."
    exit 1
fi

# Create required directories
echo "Setting up directory structure..."
mkdir -p /var/www/html/public/var
mkdir -p /var/www/html/public/plugins
mkdir -p /var/www/html/public/www/admin/plugins

# Get the hostname from environment
HOSTNAME=${RENDER_EXTERNAL_HOSTNAME:-tnadlink.onrender.com}
echo "Using hostname: $HOSTNAME"

# Copy domain configuration file
echo "Setting up domain configuration..."
cp /var/www/html/config/database.conf.php /var/www/html/public/var/${HOSTNAME}.conf.php

# Check if TN Ad Link is installed
if [ ! -f /var/www/html/public/var/INSTALLED ]; then
    echo "Running initial setup for TN Ad Link..."
    
    # Create database schema if it doesn't exist
    php /var/www/html/scripts/create-schema.php
    
    # Create installation marker
    echo "$(date)" > /var/www/html/public/var/INSTALLED
    
    echo "TN Ad Link installation completed successfully."
else
    echo "TN Ad Link is already installed."
fi

# Apply custom headers for security
echo "Setting security headers..."
cat > /etc/apache2/conf-available/security-headers.conf << EOL
<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set Content-Security-Policy "default-src 'self' https://${HOSTNAME}; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(self), microphone=(), camera=()"
</IfModule>
EOL

a2enconf security-headers

# Global ServerName to suppress warning
echo "ServerName ${HOSTNAME}" >> /etc/apache2/apache2.conf

# Set proper permissions
echo "Setting permissions..."
chmod -R 777 /var/www/html/public/var
chmod -R 777 /var/www/html/public/plugins
chmod -R 777 /var/www/html/public/www/admin/plugins
chmod -R 777 /var/www/html/var

# Clear cache
echo "Clearing cache..."
rm -rf /var/www/html/public/var/cache/* || true

# Start Apache
echo "Starting TN Ad Link server..."
apache2-foreground
