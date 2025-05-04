#!/bin/bash

# This script patches the init.php file to handle missing autoload.php

echo "Checking if init.php needs patching..."

if [ -f "/var/www/html/public/init.php" ]; then
    # Check line 45 to see if it's the problematic line
    LINE=$(sed -n '45p' /var/www/html/public/init.php)
    
    if [[ $LINE == *"require MAX_PATH . '/lib/vendor/autoload.php';"* ]]; then
        echo "Found problematic line in init.php. Patching..."
        
        # Create a backup of the original file
        cp /var/www/html/public/init.php /var/www/html/public/init.php.bak
        
        # Replace the problematic line with a try-catch block
        sed -i '45s|require MAX_PATH . \x27/lib/vendor/autoload.php\x27;|// Try to load autoload.php, but continue if not found\ntry {\n    if (file_exists(MAX_PATH . \x27/lib/vendor/autoload.php\x27)) {\n        require MAX_PATH . \x27/lib/vendor/autoload.php\x27;\n    } else {\n        // Create minimal autoloader if file doesn\x27t exist\n        spl_autoload_register(function ($class) {\n            $file = str_replace("\\\\\\\", "/", $class) . ".php";\n            if (file_exists(MAX_PATH . "/" . $file)) {\n                require_once MAX_PATH . "/" . $file;\n                return true;\n            }\n            return false;\n        });\n    }\n} catch (Exception $e) {\n    // Silently continue if autoload fails\n}|' /var/www/html/public/init.php
        
        echo "init.php patched successfully."
    else
        echo "Line 45 in init.php is not the expected problematic line."
        echo "Line content: $LINE"
    fi
else
    echo "Cannot find init.php file to patch."
fi
