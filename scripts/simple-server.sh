#!/bin/bash

echo "==== Starting simple PHP server ===="

# Create required directories
mkdir -p /var/www/html/public/www/admin
mkdir -p /var/www/html/public/var
mkdir -p /var/www/html/public/lib/vendor

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
php -S 0.0.0.0:8080
