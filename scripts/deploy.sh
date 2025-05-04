#!/bin/bash

# Log start of deployment
echo "Starting TN Ad Link deployment process..."

# Run the Apache fix script first to ensure Apache can start properly
if [ -f "/var/www/html/scripts/apache-fix.sh" ]; then
    echo "Running Apache configuration fix script..."
    bash /var/www/html/scripts/apache-fix.sh
fi

# Run the comprehensive fix script for the autoload issue
if [ -f "/var/www/html/scripts/comprehensive-fix.sh" ]; then
    echo "Running comprehensive fix script..."
    bash /var/www/html/scripts/comprehensive-fix.sh
else
    echo "Comprehensive fix script not found. Creating a basic fix..."
    
    # Minimal autoload.php creation
    mkdir -p /var/www/html/public/lib/vendor
    cat > /var/www/html/public/lib/vendor/autoload.php << 'EOL'
<?php
// Basic autoloader
spl_autoload_register(function ($class) {
    $file = str_replace('\\', '/', $class) . '.php';
    if (file_exists(__DIR__ . '/../' . $file)) {
        require_once __DIR__ . '/../' . $file;
        return true;
    }
    return false;
});
EOL
fi

# Run the installation fix script
if [ -f "/var/www/html/scripts/installation-fix.sh" ]; then
    echo "Running installation fix script..."
    bash /var/www/html/scripts/installation-fix.sh
fi

# Add admin dashboard if needed
if [ -f "/var/www/html/scripts/admin-dashboard.php" ]; then
    echo "Installing custom admin dashboard..."
    cp /var/www/html/scripts/admin-dashboard.php /var/www/html/public/www/admin/dashboard.php
    chmod 755 /var/www/html/public/www/admin/dashboard.php
fi

# Wait for database connection
echo "Checking database connection..."
php /var/www/html/scripts/wait-for-db.php
if [ $? -ne 0 ]; then
    echo "Database connection failed. Exiting."
    exit 1
fi

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

# Determine the correct port for URLs
if [ -f "/etc/apache2/ports.conf" ] && grep -q "Listen 8080" /etc/apache2/ports.conf; then
    PORT=":8080"
else
    PORT=""
fi

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
admin="https://${HOSTNAME}${PORT}/www/admin"
delivery="https://${HOSTNAME}${PORT}/delivery"
deliverySSL="https://${HOSTNAME}${PORT}/delivery"
images="https://${HOSTNAME}${PORT}/images"
imagesSSL="https://${HOSTNAME}${PORT}/images"
api="https://${HOSTNAME}${PORT}/api"

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

# Set permissions again to be sure
echo "Setting permissions..."
chmod -R 777 /var/www/html/public/var
chmod -R 777 /var/www/html/public/plugins
chmod -R 777 /var/www/html/public/www
chmod -R 777 /var/www/html/public/lib
chmod -R 777 /var/www/html/var

# Create a default welcome page
echo "Creating welcome page..."
cat > /var/www/html/public/index.php << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TN Ad Link</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background: linear-gradient(to bottom, #0057e7, #ffffff);
            color: #333;
        }
        .container {
            text-align: center;
            background-color: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 800px;
        }
        h1 {
            color: #0057e7;
            margin-bottom: 1rem;
        }
        .subtitle {
            color: #d31f1f;
            margin-bottom: 2rem;
        }
        .message {
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        .button {
            display: inline-block;
            background-color: #0057e7;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            margin-top: 1rem;
        }
        .button:hover {
            background-color: #003fb3;
        }
        .footer {
            margin-top: 2rem;
            font-size: 0.9rem;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>TN Ad Link</h1>
        <div class="subtitle">Tennessee's Premier Ad Server</div>
        
        <div class="message">
            <p>Welcome to TN Ad Link, Tennessee's premier advertising server platform!</p>
            <p>The TN Ad Link platform is running successfully.</p>
            <p>If you're an administrator, please proceed to the admin section.</p>
            
            <a href="/www/admin" class="button">Admin Panel</a>
        </div>
        
        <div class="footer">
            &copy; <?php echo date('Y'); ?> TN Ad Link. All rights reserved.
        </div>
    </div>
</body>
</html>
EOL

# Debug info
echo "Directory structure of admin directory:"
find /var/www/html/public/www/admin -type f -name "*.php" | xargs ls -la 2>/dev/null || echo "No PHP files found in admin directory"

# Check Apache configuration for errors
echo "Checking Apache configuration for errors..."
apache2ctl configtest

# Start Apache with debugging
echo "Starting TN Ad Link server..."
apache2ctl -e debug -DFOREGROUND
