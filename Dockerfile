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

# Set up runtime directory for Apache
RUN mkdir -p /var/run/apache2 \
    && echo 'Define APACHE_RUN_DIR /var/run/apache2' >> /etc/apache2/apache2.conf

# Configure PHP
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini

# Set Apache document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configure virtual host for tnadlink.com
RUN echo '<VirtualHost *:80>\n\
    ServerName tnadlink.com\n\
    ServerAlias www.tnadlink.com tnadlink.onrender.com\n\
    DocumentRoot ${APACHE_DOCUMENT_ROOT}\n\
    ErrorLog ${APACHE_LOG_DIR}/tnadlink-error.log\n\
    CustomLog ${APACHE_LOG_DIR}/tnadlink-access.log combined\n\
    <Directory ${APACHE_DOCUMENT_ROOT}>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/tnadlink.conf

# Enable site and Apache modules
RUN a2ensite tnadlink && a2enmod rewrite headers

# Create directory structure with correct permissions
RUN mkdir -p /var/www/html/public \
    /var/www/html/custom \
    /var/www/html/config \
    /var/www/html/scripts \
    /var/www/html/var/cache \
    /var/www/html/var/logs \
    /var/www/html/var/tmp \
    /var/www/html/public/var

# Copy Revive Adserver files
COPY revive/ /var/www/html/public/

# Copy application files
COPY custom/ /var/www/html/custom/
COPY config/ /var/www/html/config/
COPY scripts/ /var/www/html/scripts/

# Set permissions
RUN chmod -R 777 /var/www/html/public/var || true
RUN chmod -R 777 /var/www/html/public/plugins || true
RUN chmod -R 777 /var/www/html/public/www/admin/plugins || true
RUN chmod -R 777 /var/www/html/var || true

# Set global ServerName
RUN echo "ServerName tnadlink.onrender.com" >> /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Run deployment script
CMD ["/bin/bash", "/var/www/html/scripts/deploy.sh"]
