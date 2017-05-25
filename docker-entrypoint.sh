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

# fixFilesystemPermissions

# create a new user and run php-fpm under this user
FPM_USER='magento'
FPM_GROUP='magento'
if [ ! -z "${FPM_UID}" ] && [ ! -z "${FPM_GID}" ]; then
    addgroup -g ${FPM_GID} ${FPM_GROUP}
    adduser -u ${FPM_UID} -G ${FPM_GROUP} -g 'Linux User named' -s /sbin/nologin -D ${FPM_USER}
    sed -i "s|;*user = nobody|user = ${FPM_USER}|i" /etc/php7/php-fpm.d/www.conf
    sed -i "s|;*group = nobody|group = ${FPM_GROUP}|i" /etc/php7/php-fpm.d/www.conf
fi

# Start PHP-FPM service
exec "/usr/sbin/php-fpm7"
