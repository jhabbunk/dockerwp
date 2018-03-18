#!/bin/bash
createwpconfig(){
x=`curl -s curl -s https://api.wordpress.org/secret-key/1.1/salt/`
	echo '<?php '
	echo " define('DB_NAME', 'test');
	define('DB_USER', 'test');
	define('DB_PASSWORD', 'test');
	define('DB_HOST', '172.17.0.3');
	define('DB_CHARSET', 'utf8');
	define('DB_COLLATE', '');"
	echo $x
	echo '$table_prefix  = '\''wp_'\'';
	define('\''WP_DEBUG'\'', false);'
	echo "if ( !defined('ABSPATH') )
	        define('ABSPATH', dirname(__FILE__) . '/');
	require_once(ABSPATH . 'wp-settings.php');"
	echo ' ?>'

}
serverconfig(){
echo 'server {
    listen 8090;
    listen [::]:8090 ipv6only=on;

    root /var/www/html;
    index index.php index.html index.htm;
    location / {
                try_files $uri $uri/ =404;
        }
    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt { log_not_found off; access_log off; allow all; }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }
    location ~ \.php$ {  
	include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
}'

}

 apt-get update
 apt-get install wget curl -y
 apt-get -y install mysql-client
 apt-get install php-curl php-gd php-mysql php-mbstring php-mcrypt php-xml php-xmlrpc -y
 systemctl restart php7.0-fpm

 wget https://wordpress.org/latest.zip
 apt-get install unzip -y
 unzip latest.zip
 mkdir wordpress/wp-content/upgrade
 rm -rf /var/www/html
 cp -rfa wordpress /var/www/
 mv  /var/www/wordpress /var/www/html
 chown -R www-data:www-data /var/www/
 find /var/www/html -type d -exec chmod g+s {} \;
 chmod g+w /var/www/html/wp-content
 chmod -R g+w /var/www/html/wp-content/themes
 chmod -R g+w /var/www/html/wp-content/plugins
 echo `createwpconfig` > /var/www/html/wp-config.php
 touch /etc/nginx/sites-enabled/domains.conf
 chmod 777 /etc/nginx/sites-enabled/domains.conf
 echo `serverconfig` > /etc/nginx/sites-enabled/domains.conf

 nginx -t &> /dev/null
if [ "$?" -eq 0 ]
then
 service nginx restart
else
echo 'Nginx has some issues. Kindly solve them manually and restart'
fi
echo 'Wordpress Installed Successfully'
