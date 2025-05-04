<?php

/**
 * TN Ad Link Revive Adserver Configuration File
 * Domain-specific configuration for tnadlink.onrender.com
 */

// Database configuration
$GLOBALS['_MAX']['CONF']['database'] = array(
    'type'           => 'postgresql',
    'host'           => getenv('SUPABASE_DB_HOST'),
    'port'           => getenv('SUPABASE_DB_PORT') ?: '5432',
    'username'       => getenv('SUPABASE_DB_USER'),
    'password'       => getenv('SUPABASE_DB_PASSWORD'),
    'name'           => getenv('SUPABASE_DB_NAME'),
    'persistent'     => false,
    'protocol'       => 'https',
    'schema'         => getenv('SUPABASE_DB_SCHEMA') ?: 'tnadlink',
    'ssl'            => true,
);

// URL configuration settings
$GLOBALS['_MAX']['CONF']['webpath']['admin'] = 'https://tnadlink.onrender.com/admin';
$GLOBALS['_MAX']['CONF']['webpath']['delivery'] = 'https://tnadlink.onrender.com/delivery';
$GLOBALS['_MAX']['CONF']['webpath']['images'] = 'https://tnadlink.onrender.com/images';
$GLOBALS['_MAX']['CONF']['webpath']['api'] = 'https://tnadlink.onrender.com/api';

// Tennessee Ad Link branding
$GLOBALS['_MAX']['CONF']['ui']['applicationName'] = 'TN Ad Link';
$GLOBALS['_MAX']['CONF']['ui']['headerLogoFilename'] = '/custom/themes/tn-logo.png';

// Geotargeting configuration for Tennessee
$GLOBALS['_MAX']['CONF']['geotargeting']['type'] = 'geoip';
$GLOBALS['_MAX']['CONF']['geotargeting']['showUnavailable'] = false;

// SSL/TLS settings
$GLOBALS['_MAX']['CONF']['openads']['requireSSL'] = true;
$GLOBALS['_MAX']['CONF']['openads']['sslPort'] = 443;

// Cache settings
$GLOBALS['_MAX']['CONF']['delivery']['cache'] = true;

// Delivery settings
$GLOBALS['_MAX']['CONF']['delivery']['acls'] = true;
$GLOBALS['_MAX']['CONF']['delivery']['aclsDirectSelection'] = true;
$GLOBALS['_MAX']['CONF']['delivery']['obfuscate'] = false;

// Interface settings
$GLOBALS['_MAX']['CONF']['ui']['enabled'] = true;
$GLOBALS['_MAX']['CONF']['ui']['supportLink'] = 'mailto:admin@tnadlink.com';
$GLOBALS['_MAX']['CONF']['ui']['dashboardEnabled'] = true;

// Maintenance settings
$GLOBALS['_MAX']['CONF']['maintenance']['autoMaintenance'] = true;
$GLOBALS['_MAX']['CONF']['maintenance']['timeLimitScripts'] = 1800;

// Additional settings
$GLOBALS['_MAX']['CONF']['allowedTags'] = array('a', 'b', 'div', 'font', 'img', 'strong');
?>
