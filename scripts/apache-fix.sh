#!/bin/bash

echo "==== Running Apache Configuration Fix Script ===="

# Fix the Apache run directory issue
echo "Fixing Apache runtime directory configuration..."

# Create necessary directories
mkdir -p /var/run/apache2
chmod 755 /var/run/apache2

# Create fixed Apache configuration
cat > /tmp/apache2.conf << 'EOL'
# Global configuration
DefaultRuntimeDir /var/run/apache2
PidFile /var/run/apache2/apache2.pid
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# MPM Configuration
<IfModule mpm_prefork_module>
    StartServers             5
    MinSpareServers          5
    MaxSpareServers         10
    MaxRequestWorkers       150
    MaxConnectionsPerChild   0
</IfModule>

# Modules
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf

# Logging
LogLevel warn
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog /var/log/apache2/access.log combined
ErrorLog /var/log/apache2/error.log

# Default server configuration
ServerName tnadlink.onrender.com

# Include virtual hosts
IncludeOptional sites-enabled/*.conf
EOL

# Backup original config and replace with fixed version
if [ -f "/etc/apache2/apache2.conf" ]; then
    cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
    cp /tmp/apache2.conf /etc/apache2/apache2.conf
    echo "Apache configuration file replaced."
fi

# Fix port conflict by using a different port
echo "Checking for port conflicts..."
if netstat -tuln | grep ":80 "; then
    echo "Port 80 is already in use. Configuring Apache to use port 8080 instead."
    
    # Update virtual host configuration
    cat > /etc/apache2/sites-available/tnadlink.conf << 'EOL'
<VirtualHost *:8080>
    ServerName tnadlink.onrender.com
    ServerAlias www.tnadlink.com tnadlink.com
    DocumentRoot /var/www/html/public
    
    ErrorLog /var/log/apache2/tnadlink-error.log
    CustomLog /var/log/apache2/tnadlink-access.log combined
    
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

    # Update ports.conf to listen on 8080
    echo "Listen 8080" > /etc/apache2/ports.conf
    
    echo "Apache configured to use port 8080."
else
    echo "Port 80 is available for use."
fi

# Make sure Apache user and group are defined
echo "Defining Apache user and group..."
echo "export APACHE_RUN_USER=www-data" >> /etc/apache2/envvars
echo "export APACHE_RUN_GROUP=www-data" >> /etc/apache2/envvars

echo "==== Apache configuration fix completed ===="
