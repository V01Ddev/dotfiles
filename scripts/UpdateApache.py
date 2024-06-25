#!/bin/python3

import os


def main():

    # HTTP URL to github repo
    GITURL = ""

    # The directory name after the clone
    DIRNAME = ""

    print('[*] Clearing old files...')
    os.system('rm -r /var/www/html/*')
    os.system(f'rm -r {DIRNAME}"')

    print('[*] Cloning repo...')
    os.system(f'git clone {GITURL}')

    print('[*] Moving items...')
    os.system(f'mv {DIRNAME}/* /var/www/html/')

    print('[*] Restarting apache2')
    os.system(f'systemctl restart apache2')


if __name__ == '__main__':
    main()
