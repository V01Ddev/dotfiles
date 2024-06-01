#!/bin/bash 

# HTTP URL to github directory
GITURL = 

# The directory name after the clone
DIRNAME = 

echo [*] clearing old files...
rm -r /var/www/html/$DIRNAME
rm -r $DIRNAME


echo [*] cloning repo...
git clone $GITURL

echo [*] moving items...
mv ~/$DIRNAME /var/www/html/


echo [*] restarting nginx 
systemctl restart nginx

