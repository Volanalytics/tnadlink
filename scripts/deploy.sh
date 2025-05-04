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

# Copy configuration file
echo "Setting up database configuration..."
cp /var/www/html/config/database.conf.php /var/www/html/public/var/

# Check if TN Ad Link is installed
if [ ! -f /var/www/html/public/var/INSTALLED ]; then
    echo "Running initial setup for TN Ad Link..."
    
    # Create database schema if it doesn't exist
    php /var/www/html/scripts/create-schema.php
    
    # Run installation process
    php /var/www/html/scripts/install.php
    
    # Apply TN Ad Link branding
    echo "Applying TN Ad Link branding..."
    php /var/www/html/scripts/apply-branding.php
    
    # Create installation marker
    echo "$(date)" > /var/www/html/public/var/INSTALLED
    
    echo "TN Ad Link installation completed successfully."
else
    echo "TN Ad Link is already installed. Checking for updates..."
    php /var/www/html/scripts/check-updates.php
fi

# Apply custom headers for security
echo "Setting security headers..."
cat > /etc/apache2/conf-available/security-headers.conf << EOL
<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set Content-Security-Policy "default-src 'self' https://tnadlink.com; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(self), microphone=(), camera=()"
</IfModule>
EOL

a2enconf security-headers

# Clear cache
echo "Clearing cache..."
rm -rf /var/www/html/public/var/cache/*

# Start Apache
echo "Starting TN Ad Link server..."
apache2-foreground
