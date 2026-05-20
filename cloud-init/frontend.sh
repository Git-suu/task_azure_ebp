#!/bin/bash

apt update -y
apt install nginx -y

echo "<h1>Frontend Running</h1>" > /var/www/html/index.html

systemctl enable nginx
systemctl restart nginx