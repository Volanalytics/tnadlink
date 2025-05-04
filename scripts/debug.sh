#!/bin/bash

echo "========== DIRECTORY STRUCTURE DEBUG =========="
echo "Current working directory: $(pwd)"

# Check important files
echo "Checking for key files..."
if [ -f "/var/www/html/lib/vendor/autoload.php" ]; then
  echo "[EXISTS] /var/www/html/lib/vendor/autoload.php"
else
  echo "[MISSING] /var/www/html/lib/vendor/autoload.php"
fi

if [ -f "/var/www/html/public/lib/vendor/autoload.php" ]; then
  echo "[EXISTS] /var/www/html/public/lib/vendor/autoload.php"
else
  echo "[MISSING] /var/www/html/public/lib/vendor/autoload.php"
fi

if [ -f "/var/www/html/public/init.php" ]; then
  echo "[EXISTS] /var/www/html/public/init.php"
else
  echo "[MISSING] /var/www/html/public/init.php"
fi

# Checking PHP include path
echo "PHP include path:"
php -r 'echo get_include_path();echo "\n";'

# Check for composer.json
echo "Checking composer files..."
if [ -f "/var/www/html/composer.json" ]; then
  echo "[EXISTS] /var/www/html/composer.json"
else
  echo "[MISSING] /var/www/html/composer.json"
fi

if [ -f "/var/www/html/composer.lock" ]; then
  echo "[EXISTS] /var/www/html/composer.lock"
else
  echo "[MISSING] /var/www/html/composer.lock"
fi

# List key directories
echo "List contents of important directories:"
echo "/var/www/html directory:"
ls -la /var/www/html

echo "/var/www/html/public directory:"
ls -la /var/www/html/public

echo "/var/www/html/lib directory (if exists):"
ls -la /var/www/html/lib 2>/dev/null || echo "Directory doesn't exist"

echo "/var/www/html/public/lib directory (if exists):"
ls -la /var/www/html/public/lib 2>/dev/null || echo "Directory doesn't exist"

# Check line 45 of init.php to see what path it's trying to access
echo "Contents of line 45 in init.php:"
sed -n '44,46p' /var/www/html/public/init.php 2>/dev/null || echo "File not found or cannot access line"

echo "=============================================="
