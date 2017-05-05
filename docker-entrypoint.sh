#!/bin/sh
set -e

# Replace Xdebug remote host with ENV variable
sed -i "s|;*xdebug.remote_host=.*|xdebug.remote_host=${XDEBUG_REMOTE_HOST}|i" /etc/php7/conf.d/xdebug.ini

# Start PHP-FPM service
exec "/usr/sbin/php-fpm7"
