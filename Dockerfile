FROM php:8.1-apache

# Install required extensions and dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    libxml2-dev \
    libpng-dev \
    libicu-dev \
    libonig-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
    mbstring \
    pgsql \
    pdo \
    pdo_pgsql \
    zip \
    xml \
    gd \
    intl \
    opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set Apache document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache modules
RUN a2enmod rewrite headers

# Define Apache run user/group to avoid startup warning
RUN echo 'export APACHE_RUN_USER=www-data' >> /etc/apache2/envvars && \
    echo 'export APACHE_RUN_GROUP=www-data' >> /etc/apache2/envvars

# Configure PHP
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini

# Create directory structure
RUN mkdir -p /var/www/html/public \
    /var/www/html/custom \
    /var/www/html/config \
    /var/www/html/scripts \
    /var/www/html/var

# Create the complete directory structure for Revive Adserver
RUN mkdir -p /var/www/html/public/lib/vendor \
    /var/www/html/public/var \
    /var/www/html/public/plugins \
    /var/www/html/public/www

# Copy Revive Adserver files
COPY revive/ /var/www/html/public/

# Create a minimal vendor autoload file
RUN mkdir -p /var/www/html/public/lib/vendor && \
    echo '<?php\n\n// Minimal autoloader\nspl_autoload_register(function ($class) {\n    $file = str_replace("\\\", "/", $class) . ".php";\n    if (file_exists(__DIR__ . "/../" . $file)) {\n        require_once __DIR__ . "/../" . $file;\n        return true;\n    }\n    return false;\n});\n' > /var/www/html/public/lib/vendor/autoload.php

# Copy application files
COPY custom/ /var/www/html/custom/
COPY config/ /var/www/html/config/
COPY scripts/ /var/www/html/scripts/

# Set permissions
RUN chmod -R 777 /var/www/html/public/var
RUN chmod -R 777 /var/www/html/public/plugins
RUN chmod -R 777 /var/www/html/public/www
RUN chmod -R 777 /var/www/html/public/lib
RUN chmod -R 777 /var/www/html/var

# Set working directory
WORKDIR /var/www/html

# Run deployment script
CMD ["/bin/bash", "/var/www/html/scripts/deploy.sh"]
