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
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

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
    /var/www/html/public/var \
    /var/www/html/public/lib/vendor

# Directly copy the Revive Adserver files
COPY revive/ /var/www/html/public/

# Copy application files
COPY custom/ /var/www/html/custom/
COPY config/ /var/www/html/config/
COPY scripts/ /var/www/html/scripts/

# Create default config.inc.php file if needed
RUN if [ ! -f "/var/www/html/public/config.inc.php" ]; then \
    touch /var/www/html/public/config.inc.php; \
    chmod 777 /var/www/html/public/config.inc.php; \
fi

# Install Composer dependencies if needed
RUN if [ -f "/var/www/html/public/composer.json" ]; then \
    cd /var/www/html/public && \
    composer install --no-dev --optimize-autoloader; \
fi

# Set permissions
RUN chmod -R 777 /var/www/html/public/var || true
RUN chmod -R 777 /var/www/html/public/plugins || true
RUN chmod -R 777 /var/www/html/public/www/admin/plugins || true
RUN chmod -R 777 /var/www/html/var || true

# Set working directory
WORKDIR /var/www/html

# Run deployment script
CMD ["/bin/bash", "/var/www/html/scripts/deploy.sh"]
