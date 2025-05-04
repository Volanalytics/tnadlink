<?php
/**
 * TN Ad Link Database Configuration
 * This file will be copied to the appropriate location during deployment
 */

// Database settings
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
$GLOBALS['_MAX']['CONF']['webpath']['admin'] = 'https://tnadlink.com/admin';
$GLOBALS['_MAX']['CONF']['webpath']['delivery'] = 'https://tnadlink.com/delivery';
$GLOBALS['_MAX']['CONF']['webpath']['images'] = 'https://tnadlink.com/images';
$GLOBALS['_MAX']['CONF']['webpath']['api'] = 'https://tnadlink.com/api';

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
?>
