#!/bin/bash 


echo [*] clearing old files...
systemctl start apache2


echo [*] clearing old files...
rm -r /www/html/*

rm -r /Avocade-Web-1


echo [*] cloning repo...
git clone https://github.com/Hacker8543/Avocado-Web-1.git


echo [*] moving items...
mv ~/Avocade-Web-1/* /var/www/html


echo [*] restarting nginx 
systemctl restart apache2

