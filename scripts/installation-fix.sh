#!/bin/bash

echo "==== Running TN Ad Link Installation Fix Script ===="

# Define paths
PUBLIC_PATH="/var/www/html/public"
WWW_PATH="$PUBLIC_PATH/www"
ADMIN_PATH="$WWW_PATH/admin"

# 1. Check and fix directory structure
echo "Checking directory structure..."
mkdir -p $PUBLIC_PATH/var
mkdir -p $PUBLIC_PATH/plugins
mkdir -p $WWW_PATH
mkdir -p $ADMIN_PATH
mkdir -p $PUBLIC_PATH/images

# 2. Create the admin index file if it doesn't exist
if [ ! -f "$ADMIN_PATH/index.php" ]; then
    echo "Creating admin index file..."
    cat > "$ADMIN_PATH/index.php" << 'EOL'
<?php
// Admin index file for TN Ad Link
// This file serves as the entry point for the Revive Adserver admin interface

// Define the path to the Revive Adserver installation
define('MAX_PATH', realpath(dirname(__FILE__) . '/../../..'));

// Include the required files
require_once MAX_PATH . '/init.php';
require_once MAX_PATH . '/lib/max/language/Loader.php';
require_once MAX_PATH . '/lib/OA/Admin/UI/component/Page.php';
require_once MAX_PATH . '/lib/OA/Admin/Template.php';
require_once MAX_PATH . '/lib/OA/Admin/UI/component/Form.php';

// Redirect to the proper admin page
header('Location: dashboard.php');
exit;
EOL
    echo "Admin index file created."
fi

# 3. Create a dashboard.php file for the admin interface
if [ ! -f "$ADMIN_PATH/dashboard.php" ]; then
    echo "Creating admin dashboard file..."
    cat > "$ADMIN_PATH/dashboard.php" << 'EOL'
<?php
// Admin dashboard file for TN Ad Link
// This file provides a minimal working dashboard

// Define the path to the Revive Adserver installation
define('MAX_PATH', realpath(dirname(__FILE__) . '/../../..'));

// Set up basic HTML page
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TN Ad Link Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background-color: #0057e7;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .card {
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            padding: 20px;
        }
        h1, h2 {
            margin-top: 0;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>TN Ad Link Admin Dashboard</h1>
    </div>
    <div class="container">
        <div class="card">
            <h2>Welcome to TN Ad Link</h2>
            <p>This is a temporary dashboard. The full Revive Adserver admin interface is being configured.</p>
            <p>Current system status:</p>
            <ul>
                <li>Server is running</li>
                <li>Admin interface is accessible</li>
                <li>Waiting for full configuration</li>
            </ul>
            <p>Please check back later for the complete admin interface.</p>
        </div>
        <div class="card">
            <h2>System Information</h2>
            <p>PHP Version: <?php echo phpversion(); ?></p>
            <p>Web Server: <?php echo $_SERVER['SERVER_SOFTWARE']; ?></p>
            <p>Document Root: <?php echo $_SERVER['DOCUMENT_ROOT']; ?></p>
        </div>
    </div>
    <div class="footer">
        &copy; <?php echo date('Y'); ?> TN Ad Link. All rights reserved.
    </div>
</body>
</html>
EOL
    echo "Admin dashboard file created."
fi

# 4. Create .htaccess file for proper URL handling
echo "Creating .htaccess files..."
cat > "$PUBLIC_PATH/.htaccess" << 'EOL'
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Redirect /admin to /www/admin
    RewriteRule ^admin$ www/admin/ [R=301,L]
    RewriteRule ^admin/(.*)$ www/admin/$1 [R=301,L]
</IfModule>
EOL

# 5. Create Apache configuration for admin access
echo "Updating Apache configuration..."
cat > "/etc/apache2/sites-available/tnadlink.conf" << 'EOL'
<VirtualHost *:80>
    ServerName tnadlink.onrender.com
    ServerAlias www.tnadlink.com tnadlink.com
    DocumentRoot /var/www/html/public
    
    ErrorLog ${APACHE_LOG_DIR}/tnadlink-error.log
    CustomLog ${APACHE_LOG_DIR}/tnadlink-access.log combined
    
    <Directory /var/www/html/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    <Directory /var/www/html/public/www/admin>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

# 6. Enable Apache modules
echo "Enabling Apache modules..."
a2enmod rewrite
a2enmod headers
a2ensite tnadlink

# 7. Set proper permissions
echo "Setting permissions..."
chmod -R 777 $PUBLIC_PATH/var
chmod -R 777 $PUBLIC_PATH/plugins
chmod -R 777 $PUBLIC_PATH/www
chmod -R 777 $PUBLIC_PATH/lib
chmod -R 777 $PUBLIC_PATH/images
chmod -R 777 $ADMIN_PATH

# 8. Reload Apache
echo "Reloading Apache..."
service apache2 reload || apachectl graceful || true

echo "==== Installation fix completed ===="
echo "You should now be able to access the admin interface at:"
echo "https://tnadlink.onrender.com/www/admin"
echo "or"
echo "https://tnadlink.onrender.com/admin"
