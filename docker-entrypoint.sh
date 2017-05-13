#!/bin/sh
set -e

#####################################
# Fix the filesystem permissions for the magento root.
#####################################
function fixFilesystemPermissions() {
	chmod -R go+rw /var/www/html
}

# Replace Xdebug remote host with ENV variable
sed -i "s|;*xdebug.remote_host=.*|xdebug.remote_host=${XDEBUG_REMOTE_HOST}|i" /etc/php7/conf.d/xdebug.ini

fixFilesystemPermissions 

# Start PHP-FPM service
exec "/usr/sbin/php-fpm7"
