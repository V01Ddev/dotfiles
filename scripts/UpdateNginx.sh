#!/bin/bash 

# HTTP URL to github directory
GITURL=''

# The directory name after the clone
DIRNAME=''

# The directory that nginx references
WDIR='/var/www/html/' # Default on Debian

echo [*] clearing old files...
rm -r $WDIR/*
rm -r $DIRNAME


echo [*] cloning repo...
git clone $GITURL

echo [*] moving items...
cp -r ~/$DIRNAME/* $WDIR


echo [*] restarting nginx 
systemctl restart nginx

