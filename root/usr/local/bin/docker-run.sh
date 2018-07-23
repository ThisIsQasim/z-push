#!/bin/bash

mkdir -p /state /var/log/z-push
touch /var/log/z-push/z-push-error.log /var/log/z-push/z-push.log

chown -R zpush:zpush /state /opt/zpush /var/log/z-push

cp /etc/supervisord.conf.dist /etc/supervisord.conf
[ "$DEBUG" = 1 ] && sed -i "|z-push-error.log|z-push-error.log /var/log/z-push/z-push.log|" /etc/supervisord.conf



# setting up logrotate
echo -e "/var/log/z-push/z-push.log\n{\n  compress\n  copytruncate\n  delaycompress\n rotate 7\n  daily\n}" > /etc/logrotate.d/z-pushlog
echo -e "/var/log/z-push/z-push.log\n{\n  compress\n  copytruncate\n  delaycompress\n rotate 4\n  weekly\n}" > /etc/logrotate.d/z-push-errorlog

echo "*************************BEGIN* config.php *BEGIN******************************"
echo "==============================================================================="
cat /opt/zpush/config.php
echo "***************************END* config.php *END********************************"
echo "==============================================================================="

echo "*************************BEGIN* imap.php *BEGIN******************************"
echo "==============================================================================="
cat /opt/zpush/backend/imap/config.php
echo "***************************END* imap.php *END********************************"
echo "==============================================================================="

# run application
echo "Starting supervisord..."
/usr/bin/supervisord -c /etc/supervisord.conf
