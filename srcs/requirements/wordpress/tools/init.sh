#!/bin/bash

set -e

DB_NAME=$(cat /run/secrets/db_name)
DB_USER=$(cat /run/secrets/db_user)
DB_PASS=$(cat /run/secrets/db_password)
DB_HOST="${DB_HOST:-mariadb}"

WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_URL="https://${DOMAIN_NAME:-abbenmou.42.fr}"

WP_USER=$(cat /run/secrets/wp_user)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)
WP_USER_EMAIL=$(cat /run/secrets/wp_user_email)

WP_DIR=/var/www/html

mkdir -p "$WP_DIR"
chown -R www-data:www-data "$WP_DIR"

mkdir -p /var/www/.wp-cli
chown -R www-data:www-data /var/www/.wp-cli

until mysqladmin ping -h "$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent; do
    echo "Waiting for database connection..."
    sleep 1
done

if [ ! -s "$WP_DIR/wp-config.php" ]; then
echo "Installing WordPress..." && \
su -s /bin/bash www-data -c "
        if [ ! -f '$WP_DIR/wp-load.php' ]; then
            wp core download --path='$WP_DIR' --locale=en_US
        fi &&
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