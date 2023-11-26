#!/bin/python3 
import os


# backup_path = "~/SmbServer/"
# media = "192.168.100.59"

# dir that media is mounted to 
backup_path = "/mnt/"



# path to mdeia to backup to / getting backup media path
def get_media():
    os.system("lsblk")
    media = str(input("backup media (without the /dev/) --> "))
    media = "/dev/" + media
    return media



def mount_check():

    mbp = backup_path[2:]
    print(mbp)

    response = os.path.exists(f"/home/v01d/{mbp}BACKUP/checkfile.txt")
    print(f"mount check res --> {response}")

    if response:
        print("[*] Media was mounted")
        return True

    else:
        print("[*] Media not mounted")
        print(f"[*] Mounting {media} to {backup_path}")

        # os.system(f"sudo mount -t cifs -o username=v01d,password='Ar8822977@trueNAS' //192.168.100.59/DataHaven {SMB_backup_path}")
        try:
            os.system(f"sudo mount {media} {backup_path}")
            return True

        except:
            print(f"[*] Error mounting {media}")
            return False


def media_check():

    if os.path.exists(media):
        print("[*] Media is connected")
        return True
    else:
        print("[*] Media device not found")



def main(media):

    # Paths to backup
    paths = ["/home/v01d/Pictures", "/home/v01d/CODING", "/home/v01d/scripts", "/home/v01d/Documents"]

    # Checks if media is connected 
    media_status = media_check()

    # Checks if path is mounted
    mounted = mount_check()

    if mounted and media_status:

        for path in paths:
            dir_name = path[2:]
            os.system(f"sudo rsync -rP --delete {path} {backup_path}/BACKUP/ ")

        # os.system(f"sudo umount {backup_path}")


    else:
        print("[*] ERROR!")
        exit() 



if __name__ == "__main__":

    usr_id = int(os.getuid())

    if usr_id == 0:
        media = get_media()
        main(media)
    else:
        print("[*] Root access is required, quiting✌ ... ")

