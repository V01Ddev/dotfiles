#!/bin/bash 


# HTTP URL to github repo
GITURL = 

# The directory name after the clone
DIRNAME = 

echo [*] clearing old files...
rm -r /var/www/html/*
rm -r $DIRNAME


echo [*] cloning repo...
git $GITURL


echo [*] moving items...
mv ~/$DIRNAME/* /var/www/html/

echo [*] restarting apache2
systemctl restart apache2

