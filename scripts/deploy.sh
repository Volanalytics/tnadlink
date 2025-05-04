#!/bin/bash

# Log start of deployment
echo "Starting TN Ad Link deployment process..."

# Create the autoload.php file if it doesn't exist
if [ ! -f "/var/www/html/public/lib/vendor/autoload.php" ]; then
    echo "Creating autoload.php file..."
    mkdir -p /var/www/html/public/lib/vendor
    cat > /var/www/html/public/lib/vendor/autoload.php << 'EOL'
<?php

// Minimal autoloader
spl_autoload_register(function ($class) {
    $file = str_replace("\\", "/", $class) . ".php";
    if (file_exists(__DIR__ . "/../" . $file)) {
        require_once __DIR__ . "/../" . $file;
        return true;
    }
    return false;
});
EOL
    echo "Created autoload.php file."
fi

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

# Get database credentials from environment
DB_HOST=$(echo $SUPABASE_DB_HOST)
DB_PORT=$(echo ${SUPABASE_DB_PORT:-5432})
DB_USER=$(echo $SUPABASE_DB_USER)
DB_PASS=$(echo $SUPABASE_DB_PASSWORD)
DB_NAME=$(echo $SUPABASE_DB_NAME)
DB_SCHEMA=$(echo ${SUPABASE_DB_SCHEMA:-tnadlink})

# Create domain configuration file
echo "Creating domain configuration file..."
cat > /var/www/html/public/var/${HOSTNAME}.conf.php << EOL
;<?php exit; ?>
;*** DO NOT REMOVE THE LINE ABOVE ***

[database]
type=postgresql
host="$DB_HOST"
port="$DB_PORT"
username="$DB_USER"
password="$DB_PASS"
name="$DB_NAME"
persistent=false
protocol=https
schema="$DB_SCHEMA"
ssl=true

[webpath]
admin="https://${HOSTNAME}/admin"
delivery="https://${HOSTNAME}/delivery"
deliverySSL="https://${HOSTNAME}/delivery"
images="https://${HOSTNAME}/images"
imagesSSL="https://${HOSTNAME}/images"
api="https://${HOSTNAME}/api"

[ui]
applicationName="TN Ad Link"
headerLogoFilename="/custom/themes/tn-logo.png"
enabled=true
supportLink="mailto:admin@tnadlink.com"
dashboardEnabled=true

[geotargeting]
type=geoip
showUnavailable=false

[openads]
requireSSL=true
sslPort=443

[delivery]
cache=true
acls=true
aclsDirectSelection=true
obfuscate=false

[maintenance]
autoMaintenance=true
timeLimitScripts=1800

[store]
webDir="/var/www/html/public/var"

[allowedTags]
items[]="a"
items[]="b"
items[]="div"
items[]="font"
items[]="img"
items[]="strong"
EOL

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

# Set proper permissions
echo "Setting permissions..."
chmod -R 777 /var/www/html/public/var
chmod -R 777 /var/www/html/public/plugins
chmod -R 777 /var/www/html/public/www
chmod -R 777 /var/www/html/public/lib
chmod -R 777 /var/www/html/var

# Output init.php contents for debugging
echo "Contents of init.php line 45:"
sed -n '44,46p' /var/www/html/public/init.php 2>/dev/null || echo "Cannot access init.php"

# Output directory listing for debugging
echo "Directory structure:"
ls -la /var/www/html/public/lib/vendor

# Start Apache
echo "Starting TN Ad Link server..."
exec apache2-foreground
