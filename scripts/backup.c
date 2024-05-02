#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>


// Creates/Checks directory to mount to
void CreateBackupPoint(){
    char path[] = "/mnt/backup_point/";

    DIR *dirptr = opendir(path);

    if (dirptr == NULL){
        printf("[*] Creating /mnt/backup_point/ to use as mounting point.\n");
        system("mkdir /mnt/backup_point/\n");
        dirptr = opendir(path);
        if (dirptr == NULL){
            printf("[*] Couldn't create /mnt/backup_point\n");
            exit(1);
        }
    }
    else{
        printf("[*] Mounting to /mnt/backup_point/\n");
    }
}


// Check privileges of the user running the script
void CheckPriv()
{
    if (geteuid() == 0) {
        printf("[*] Running as root\n");
    } else {
        printf("[*] Please run as root\n");
        exit(1);
    }
}


char* CombS(char *s1, char *s2)
{
    int TotalSize = strlen(s1)+strlen(s2)+1;
    char *sr = (char *)malloc(TotalSize);
    strcpy(sr, s1);
    strcat(sr, s2);
    return sr;
}


char* AddDev(char *s)
{
    char d[5] = "/dev/";
    int TotalSize = strlen(s)+strlen(d)+1;
    char *sr = (char *)malloc(TotalSize);
    strcpy(sr, d);
    strcat(sr, s);
    return sr;
}


int main()
{

    char Media[4];
    char BackupType;

    CheckPriv();
    CreateBackupPoint();

    char paths[4][21] = {"/home/v01d/Pictures", "/home/v01d/CODING", "/home/v01d/Documents"};

    printf("[*] Quick or Full backup? (q or f) --> ");
    scanf("%c", &BackupType);

    if (BackupType == 'q'){
        printf("[*] Running quick backup\n");
    } else if (BackupType == 'f'){
        printf("[*] Running full backup\n");
    } else{
        printf("[*] Invalid input\n");
        exit(1);
    }

    system("lsblk");
    printf("[*] The backup media (without the /dev/) --> ");
    scanf("%s", Media);

    char *MediaPath = AddDev(Media);

    char *t = CombS("mount ", MediaPath);
    char *MountArg = CombS(t, " /mnt/backup_point");

    // mounts to /mnt/backup_point
    int s = system(MountArg);

    if (s==0){
        printf("[*] Mounted without issues\n");
    } else{
        printf("[*] Error Mounting");
        exit(1);
    }

    if (BackupType=='f'){
        char cmd_1[] = "rsync -rvt --delete ";
        for (int i=0; i < (sizeof(paths)/20)-1; i++){
            char *cmd_2[90];
            char *cmd_3[59];
            char *full_cmd[59];
            *cmd_2 = CombS(cmd_1, paths[i]);

            *full_cmd = CombS(*cmd_2, " /mnt/backup_point");

            system(*full_cmd);
        }
        char *u_cmd = CombS("umount ", MediaPath);
        system(u_cmd);
    } else if (BackupType=='q'){

        char cmd_1[] = "rsync -rt --ignore-existing --list-only ";
        for (int i=0; i < (sizeof(paths)/20)-1; i++){
            char *cmd_2[90];
            char *cmd_3[59];
            char *full_cmd[59];
            *cmd_2 = CombS(cmd_1, paths[i]);

            *full_cmd = CombS(*cmd_2, " /mnt/backup_point");

            system(*full_cmd);
        }
        char *u_cmd = CombS("umount ", MediaPath);
        system(u_cmd);
    }
    else{
        printf("[*] Unknown Error, Unmounting\n");
        char *u_cmd = CombS("umount ", MediaPath);
        system(u_cmd);
        exit(1);
    }
    return 0;
}
