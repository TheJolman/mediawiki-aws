#!/bin/bash

# Pull the config file and logo
aws s3 cp s3://"${S3_CONFIG_BUCKET}"/"${S3_CONFIG_FILE}" /var/www/html/LocalSettings.php
aws s3 cp s3://"${S3_CONFIG_BUCKET}"/"${S3_LOGO_FILE}" /var/www/html/resources/assets/wiki.png

echo "Replacing wgServer value with ALB URL: $MEDIAWIKI_SERVER_URL"
sed -E -i "s|^\s*\\\$wgServer\s*=.*;|\$wgServer = \"$MEDIAWIKI_SERVER_URL\";|" /var/www/html/LocalSettings.php

# Set folder ownership to www-data (prevents read/write permission issues)
chown -R www-data /var/www/html/imagesLink
chown -R www-data /var/www/html/images

exec "$@"
