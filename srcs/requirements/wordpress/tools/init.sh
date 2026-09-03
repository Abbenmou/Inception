#!/bin/bash

set -e

DB_NAME=$(cat /run/secrets/db_name)
DB_USER=$(cat /run/secrets/db_user)
DB_PASS=$(cat /run/secrets/db_password)
DB_HOST="${DB_HOST:-mariadb}"

WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_URL="${DOMAIN_NAME:-abbenmou.42.fr}"

WP_DIR=/var/www/html

mkdir -p "$WP_DIR"
chown -R www-data:www-data "$WP_DIR"

until mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" &>/dev/null; do
  sleep 1
done

if [ ! -f "$WP_DIR/wp-config.php" ]; then
    echo "Installing WordPress..." && \
    su -s /bin/bash www-data -c "
        wp core download \
            --path='$WP_DIR' \
            --locale=en_US &&
    
        wp config create \
            --path='$WP_DIR' \
            --dbname='$DB_NAME' \
            --dbuser='$DB_USER' \
            --dbpass='$DB_PASS' \
            --dbhost='$DB_HOST' &&
    
        wp core install \
            --path='$WP_DIR' \
            --url='$WP_URL' \
            --title='Inception' \
            --admin_user='$WP_ADMIN_USER' \
            --admin_password='$WP_ADMIN_PASS' \
            --admin_email='$WP_ADMIN_EMAIL' \
            --skip-email &&

        wp user create \
            '$WP_USER' \
            '$WP_USER_EMAIL' \
            --user_pass='$WP_USER_PASS' \
            --path='$WP_DIR'
    "

fi

chown -R www-data:www-data "$WP_DIR"

exec php-fpm8.2 -F