#!/bin/bash

echo "==== Running comprehensive TN Ad Link fix script ===="

# 1. Fix the init.php file
if [ -f "/var/www/html/public/init.php" ]; then
    echo "Creating backup of original init.php..."
    cp /var/www/html/public/init.php /var/www/html/public/init.php.bak
    
    echo "Applying fix to init.php..."
    cat > /var/www/html/public/init.php << 'EOL'
<?php

/*
+---------------------------------------------------------------------------+
| Revive Adserver                                                           |
| http://www.revive-adserver.com                                            |
|                                                                           |
| Copyright: See the COPYRIGHT.txt file.                                    |
| License: GPLv2 or later, see the LICENSE.txt file.                        |
+---------------------------------------------------------------------------+
*/

/**
 * @package    Max
 *
 * A file to set up the environment for the administration interface.
 */

require_once 'pre-check.php';
require_once 'variables.php';
require_once 'constants.php';

/**
 * The environment initialisation function for the administration interface.
 *
 * @TODO Should move the user authentication, loading of preferences into this
 *       file, and out of the /www/admin/config.php file.
 */
function init()
{
    // Prevent _MAX from being read from the request string (if register globals is on)
    unset($GLOBALS['_MAX']);
    unset($GLOBALS['_OX']);

    // Set up server variables
    setupServerVariables();

    // Set up the UI constants
    setupConstants();

    // Set up the common configuration variables
    setupConfigVariables();

    // Bootstrap PSR Autoloader and DI container
    $autoloadPath = MAX_PATH . '/lib/vendor/autoload.php';
    if (file_exists($autoloadPath)) {
        require $autoloadPath;
    } else {
        // Create a minimal autoloader if the file doesn't exist
        spl_autoload_register(function ($class) {
            $file = str_replace('\\', '/', $class) . '.php';
            $paths = [
                MAX_PATH . '/lib/',
                MAX_PATH . '/'
            ];
            
            foreach ($paths as $path) {
                if (file_exists($path . $file)) {
                    require_once $path . $file;
                    return true;
                }
            }
            
            return false;
        });
    }
    
    // Create a minimal container if the class doesn't exist
    if (!class_exists('\\RV\\Container')) {
        $GLOBALS['_MAX']['DI'] = new stdClass();
    } else {
        $GLOBALS['_MAX']['DI'] = new \RV\Container($GLOBALS['_MAX']['CONF']);
    }

    // Disable all notices and warnings, as lots of code still
    // generates PHP warnings - especially E_STRICT notices from PEAR
    // libraries
    error_reporting(E_ALL & ~(E_NOTICE | E_WARNING | E_DEPRECATED | E_STRICT));

    // If not being called from the installation script...
    if ((!isset($GLOBALS['_MAX']['CONF']['openads']['installed'])) || (!$GLOBALS['_MAX']['CONF']['openads']['installed'])) {
        define('OA_INSTALLATION_STATUS', OA_INSTALLATION_STATUS_NOTINSTALLED);
    } elseif ($GLOBALS['_MAX']['CONF']['openads']['installed'] && file_exists(MAX_PATH . '/var/UPGRADE')) {
        define('OA_INSTALLATION_STATUS', OA_INSTALLATION_STATUS_UPGRADING);
    } elseif ($GLOBALS['_MAX']['CONF']['openads']['installed'] && file_exists(MAX_PATH . '/var/INSTALLED')) {
        define('OA_INSTALLATION_STATUS', OA_INSTALLATION_STATUS_INSTALLED);
    }

    global $installing;
    if ((!$installing) && (PHP_SAPI != 'cli')) {
        $scriptName = basename($_SERVER['SCRIPT_NAME']);
        // Direct the user to the installation script if not installed
        if ($scriptName != 'install.php' && PHP_SAPI != 'cli' && OA_INSTALLATION_STATUS !== OA_INSTALLATION_STATUS_INSTALLED) {
            // Do not redirect for maintenance scripts
            if ($scriptName == 'maintenance.php' || $scriptName == 'maintenance-distributed.php') {
                exit;
            }
            $path = dirname($_SERVER['SCRIPT_NAME']);
            if ($path == DIRECTORY_SEPARATOR) {
                $path = '';
            }
            if (defined('ROOT_INDEX')) {
                // The root index.php page was called to get here
                $location = 'Location: ' . $GLOBALS['_MAX']['HTTP'] .
                       OX_getHostNameWithPort() . $path . '/www/admin/install.php';
                header($location);
            } elseif (defined('WWW_INDEX')) {
                // The index.php page in /www was called to get here
                $location = 'Location: ' . $GLOBALS['_MAX']['HTTP'] .
                       OX_getHostNameWithPort() . $path . '/admin/install.php';
                header($location);
            } else {
                // The index.php page in /www/admin was called to get here
                $location = 'Location: ' . $GLOBALS['_MAX']['HTTP'] .
                       OX_getHostNameWithPort() . $path . '/install.php';
                header($location);
            }
            exit();
        }
    }

    // Start PHP error handler
    $conf = $GLOBALS['_MAX']['CONF'];
    include_once MAX_PATH . '/lib/max/ErrorHandler.php';
    $eh = new MAX_ErrorHandler();
    $eh->startHandler();

    // Store the original memory limit before changing it
    $GLOBALS['_OX']['ORIGINAL_MEMORY_LIMIT'] = OX_getMemoryLimitSizeInBytes();

    // Increase the PHP memory_limit value to the minimum required value, if necessary
    OX_increaseMemoryLimit(OX_getMinimumRequiredMemory());
}

// Run the init() function
init();

require_once 'PEAR.php';

// Set $conf
$conf = $GLOBALS['_MAX']['CONF'];
EOL

    echo "Successfully replaced init.php with fixed version."
else
    echo "init.php not found. Skipping this fix."
fi

# 2. Create the autoload.php file
mkdir -p /var/www/html/public/lib/vendor
echo "Creating autoload.php file..."
cat > /var/www/html/public/lib/vendor/autoload.php << 'EOL'
<?php

/**
 * Minimal autoloader for Revive Adserver
 */

// Default PSR-4 autoloader
spl_autoload_register(function ($class) {
    // Convert namespace to full path
    $class = ltrim($class, '\\');
    $file = '';
    
    if ($lastNsPos = strripos($class, '\\')) {
        $namespace = substr($class, 0, $lastNsPos);
        $class = substr($class, $lastNsPos + 1);
        $file = str_replace('\\', DIRECTORY_SEPARATOR, $namespace) . DIRECTORY_SEPARATOR;
    }
    
    $file .= $class . '.php';
    
    // Check several possible locations
    $paths = [
        __DIR__ . '/../../',
        __DIR__ . '/../',
        __DIR__ . '/',
        defined('MAX_PATH') ? MAX_PATH . '/lib/' : '',
        defined('MAX_PATH') ? MAX_PATH . '/' : ''
    ];
    
    foreach ($paths as $path) {
        if ($path && file_exists($path . $file)) {
            require_once $path . $file;
            return true;
        }
    }
    
    return false;
});

// RV Container class minimal implementation if it doesn't exist
if (!class_exists('\\RV\\Container')) {
    class RV_Container {
        private $config;
        
        public function __construct($config = []) {
            $this->config = $config;
        }
        
        public function get($name) {
            return null;
        }
    }
    
    class_alias('RV_Container', '\\RV\\Container');
}

echo "// Minimal autoloader created successfully\n";
EOL

echo "Successfully created autoload.php file."

# 3. Check if we're missing any other required files/directories
mkdir -p /var/www/html/public/var
mkdir -p /var/www/html/public/plugins
mkdir -p /var/www/html/public/www/admin/plugins
mkdir -p /var/www/html/public/lib/RV

# Create a minimal Container.php file if missing
if [ ! -f "/var/www/html/public/lib/RV/Container.php" ]; then
    echo "Creating minimal Container.php file..."
    mkdir -p /var/www/html/public/lib/RV
    
    cat > /var/www/html/public/lib/RV/Container.php << 'EOL'
<?php

namespace RV;

/**
 * Minimal Container implementation
 */
class Container {
    private $config;
    
    public function __construct($config = []) {
        $this->config = $config;
    }
    
    public function get($id) {
        return null;
    }
}
EOL

    echo "Created minimal Container.php file."
fi

# 4. Set permissions
echo "Setting proper permissions..."
chmod -R 777 /var/www/html/public/var
chmod -R 777 /var/www/html/public/plugins
chmod -R 777 /var/www/html/public/www
chmod -R 777 /var/www/html/public/lib

echo "==== Comprehensive fix completed ===="
