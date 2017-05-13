# Use Alpine Linux
FROM alpine

# Maintainer
MAINTAINER Hans Phung <hanh201288@gmail.com>

# Environments
ENV TIMEZONE             UTC
ENV MAX_EXECUTION_TIME   1800
ENV MAX_INPUT_TIME       60
ENV MEMORY_LIMIT         512M
ENV UPLOAD_MAX_FILESIZE  32M
ENV MAX_FILE_UPLOADS     10
ENV POST_MAX_SIZE        100M
ENV XDEBUG_REMOTE_HOST   localhost

# Let's roll
RUN	apk update && \
	apk upgrade && \

    # Set proper time zone
	apk add tzdata && \
	cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo "${TIMEZONE}" > /etc/timezone && \

	# PHP 7 essentials
	apk add \
        php7-bcmath \
        php7-bz2 \
        php7-ctype \
        php7-curl \
        php7-dom \
        php7-gd \
        php7-gettext \
        php7-gmp \
        php7-iconv \
        php7-json \
        php7-mcrypt \
        php7-opcache \
        php7-openssl \
        php7-soap \
        php7-xmlreader \
        php7-xmlrpc \
        php7-zip \
        php7-zlib \
        php7-session \
        php7-mbstring && \

	# PHP 7 database drivers
	apk add \
		php7-mysqli \
		php7-sqlite3 \
		php7-odbc \
		php7-pdo \
		php7-pdo_odbc \
		php7-pdo_pgsql \
		php7-pdo_mysql \
		php7-pdo_sqlite \
		php7-pdo_dblib && \

	# PHP 7 caching and debuging, needed only in FPM
	apk add \
        php7-xdebug \
		php7-fpm && \

	# PHP 7 needed only for CLI
	apk add \
        php7-phar \
		php7 && \

    # Set environments
    # Changes to php-fpm.conf
	sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \

    # Changes to php-fpm pool www.conf
	sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php7/php-fpm.d/www.conf && \
	sed -i "s|;*listen\s*=\s*/||g" /etc/php7/php-fpm.d/www.conf && \
    
    # Changes to php.ini
	sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini && \
	sed -i "s|;*memory_limit =.*|memory_limit = ${MEMORY_LIMIT}|i" /etc/php7/php.ini && \
	sed -i "s|;*max_execution_time =.*|max_execution_time = ${MAX_EXECUTION_TIME}|i" /etc/php7/php.ini && \
	sed -i "s|;*max_input_time =.*|max_input_time = ${MAX_INPUT_TIME}|i" /etc/php7/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${UPLOAD_MAX_FILESIZE}|i" /etc/php7/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${MAX_FILE_UPLOADS}|i" /etc/php7/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${POST_MAX_SIZE}|i" /etc/php7/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini && \

    # Symlink php7 to php
    ln -s /usr/bin/php7 /usr/bin/php && \
    # Remove default opcache.ini and replace with our custom file later
    find /etc/php7/conf.d -name "*opcache.ini" -type f -delete && \

    # Install n98-magerun
    apk add curl && \
	curl -O https://files.magerun.net/n98-magerun.phar && \
    chmod +x ./n98-magerun.phar && \
    cp ./n98-magerun.phar /usr/local/bin/magerun && \
    rm ./n98-magerun.phar && \

    # Cleaning up
	mkdir -p /var/www/html/ && \
	apk del tzdata && \
	apk del curl && \
	rm -rf /var/cache/apk/*

# Copy custom PHP configurations
COPY conf.d/* /etc/php7/conf.d/
# Copy docker-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/

# Set Workdir
WORKDIR /var/www/html

# Expose volumes
VOLUME ["/var/www/html"]

# Expose ports
EXPOSE 9000 9009

# Entry point
ENTRYPOINT ["docker-entrypoint.sh"]
