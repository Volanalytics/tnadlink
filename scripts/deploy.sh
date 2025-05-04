#!/bin/bash

# Log start of deployment
echo "Starting TN Ad Link deployment process..."

# Create required directories
mkdir -p /var/www/html/public/www/admin
mkdir -p /var/www/html/public/var
mkdir -p /var/www/html/public/lib/vendor

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
admin="https://${HOSTNAME}/www/admin"
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

# Create a simple admin page
cat > /var/www/html/public/www/admin/index.php << 'EOL'
<?php
// Simple admin page for TN Ad Link
$year = date('Y');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TN Ad Link Admin</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 30px auto;
            padding: 20px;
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        header {
            background-color: #0057e7;
            color: white;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
        }
        h1, h2 {
            margin-top: 0;
        }
        .card {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <header>
        <h1>TN Ad Link Admin Dashboard</h1>
    </header>
    <div class="container">
        <div class="card">
            <h2>Welcome to TN Ad Link Administration</h2>
            <p>This is a simplified admin dashboard for the TN Ad Link platform.</p>
            <p>System Status: Running</p>
        </div>
        
        <div class="card">
            <h2>Server Information</h2>
            <ul>
                <li>PHP Version: <?php echo phpversion(); ?></li>
                <li>Server Software: <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'PHP Built-in Server'; ?></li>
                <li>Document Root: <?php echo $_SERVER['DOCUMENT_ROOT'] ?? getcwd(); ?></li>
                <li>Current Time: <?php echo date('Y-m-d H:i:s'); ?></li>
            </ul>
        </div>
        
        <div class="card">
            <h2>Quick Links</h2>
            <ul>
                <li><a href="/">Home Page</a></li>
                <li><a href="/www/admin">Admin Dashboard</a></li>
            </ul>
        </div>
        
        <div class="footer">
            &copy; <?php echo $year; ?> TN Ad Link. All rights reserved.
        </div>
    </div>
</body>
</html>
EOL

# Create a simple home page
cat > /var/www/html/public/index.php << 'EOL'
<?php
// Simple home page for TN Ad Link
$year = date('Y');
?>
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
            min-height: 100vh;
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
            width: 90%;
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
            <p>The TN Ad Link platform is now running.</p>
            <p>If you're an administrator, you can access the admin panel below:</p>
            
            <a href="/www/admin" class="button">Admin Panel</a>
        </div>
        
        <div class="footer">
            &copy; <?php echo $year; ?> TN Ad Link. All rights reserved.
        </div>
    </div>
</body>
</html>
EOL

# Set up autoloader
mkdir -p /var/www/html/public/lib/vendor
cat > /var/www/html/public/lib/vendor/autoload.php << 'EOL'
<?php
// Minimal autoloader for TN Ad Link
spl_autoload_register(function ($class) {
    $file = str_replace('\\', '/', $class) . '.php';
    if (file_exists(__DIR__ . '/../' . $file)) {
        require_once __DIR__ . '/../' . $file;
        return true;
    }
    return false;
});
echo "// Minimal autoloader created\n";
EOL

# Set file permissions
chmod -R 755 /var/www/html/public

# Start PHP's built-in web server
cd /var/www/html/public
echo "Starting PHP built-in web server on port 8080..."
exec php -S 0.0.0.0:8080
