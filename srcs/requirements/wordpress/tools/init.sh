#!/bin/bash
set -e

DB_NAME=$(cat /run/secrets/db_name.txt)
DB_USER=$(cat /run/secrets/db_user.txt)
DB_PASS=$(cat /run/secrets/db_password.txt)
DB_HOST="${DB_HOST:-mariadb}"

WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user.txt)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password.txt)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email.txt)
WP_URL="${DOMAIN_NAME:-abbenmou.42.fr}"

WP_DIR=/var/www/html

mkdir -p "$WP_DIR"


if [ ! -f "$WP_DIR/wp-config.php" ]; then
    su -s /bin/bash www-data -c "
        wp core download --path='$WP_DIR' --locale=en_US \
        && wp config create \
                --path='$WP_DIR' \
                --dbname='$DB_NAME' \
                --dbuser='$DB_USER' \
                --dbpass='$DB_PASS' \
                --dbhost='$DB_HOST' \
        && wp core install \
                --path='$WP_DIR' \
                --url='$WP_URL' \
                --title="Inception" \
                --admin_user='$WP_ADMIN_USER' \
                --admin_password='$WP_ADMIN_PASS' \
                --admin_email='$WP_ADMIN_EMAIL' \
                --skip-email
    "
fi
chown -R www-data:www-data "$WP_DIR"

exec php-fpm8.2 -F