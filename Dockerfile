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

# Set working directory
WORKDIR /var/www/html

# Copy Revive Adserver files - this is the key difference - we copy to the html root first
COPY revive/ /var/www/html/

# Copy application files
COPY custom/ /var/www/html/custom/
COPY config/ /var/www/html/config/
COPY scripts/ /var/www/html/scripts/

# Fix the directory structure by copying all needed files to public directory
RUN cp -R /var/www/html/lib /var/www/html/public/ && \
    cp -R /var/www/html/plugins /var/www/html/public/ && \
    cp -R /var/www/html/www /var/www/html/public/ && \
    cp -R /var/www/html/*.php /var/www/html/public/ && \
    cp -R /var/www/html/*.txt /var/www/html/public/ && \
    cp -R /var/www/html/*.md /var/www/html/public/ && \
    cp -R /var/www/html/*.xml /var/www/html/public/ && \
    cp -R /var/www/html/*.html /var/www/html/public/ && \
    cp -R /var/www/html/var /var/www/html/public/ || true

# Install composer dependencies
WORKDIR /var/www/html
RUN if [ -f composer.json ]; then \
    composer install --no-dev --no-interaction --optimize-autoloader; \
    fi

# Set permissions
RUN chmod -R 777 /var/www/html/public/var || true
RUN chmod -R 777 /var/www/html/public/plugins || true
RUN chmod -R 777 /var/www/html/public/www/admin/plugins || true
RUN chmod -R 777 /var/www/html/var || true
RUN chmod -R 777 /var/www/html/public/lib || true

# Set global ServerName
RUN echo "ServerName tnadlink.onrender.com" >> /etc/apache2/apache2.conf

# Set working directory back to /var/www/html
WORKDIR /var/www/html

# Define Apache run user/group to avoid startup warning
RUN echo 'export APACHE_RUN_USER=www-data' >> /etc/apache2/envvars && \
    echo 'export APACHE_RUN_GROUP=www-data' >> /etc/apache2/envvars

# Run deployment script
CMD ["/bin/bash", "/var/www/html/scripts/deploy.sh"]
