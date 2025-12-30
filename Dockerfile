FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libssl-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libsodium-dev \
    zip \
    unzip \
    vim \
    wget \
    gnupg \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Magento
# Note: curl, ctype, fileinfo, filter, hash, iconv, openssl, and tokenizer are built-in
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    dom \
    ftp \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    simplexml \
    soap \
    sockets \
    sodium \
    xsl \
    zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --version=2.2.21 --install-dir=/usr/local/bin --filename=composer

# Configure PHP
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/memory_limit = .*/memory_limit = 4G/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/max_execution_time = .*/max_execution_time = 18000/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/zlib.output_compression = .*/zlib.output_compression = On/' "$PHP_INI_DIR/php.ini"

# Install Xdebug for debugging
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
    && echo "xdebug.client_host=host.docker.internal" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
    && echo "xdebug.client_port=9003" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"

# Configure www-data user for VS Code and Magento
RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data \
    && usermod -d /workspace www-data \
    && usermod -s /bin/bash www-data

# Set working directory
WORKDIR /workspace

# Change ownership
RUN chown -R www-data:www-data /workspace

# PHP-FPM runs as root but worker processes run as www-data
CMD ["php-fpm"]
