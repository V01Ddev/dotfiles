#!/bin/bash 


echo [*] clearing old files...

rm -r /www/html/*

rm -r v01d-website


echo [*] cloning repo...

git clone https://github.com/V01Ddev/v01d-website.git


echo [*] moving items...
mv ~/v01d-website/* /var/www/html


echo [*] restarting nginx 
systemctl restart nginx

