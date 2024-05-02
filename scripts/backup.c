#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


// Check privileges of the user running the script
void CheckPriv()
{
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
    

    char paths[4][21] = {"/home/v01d/Pictures", "/home/v01d/CODING", "/home/v01d/scripts", "/home/v01d/Documents"};


    printf("[*] Please ensure backup media is mounted and running with sudo\n");
    printf("[*] Quick or Full backup? (q or f) --> ");

    scanf("%c", &BackupType);
    system("lsblk");
    printf("[*] The backup media (without the /dev/) --> ");
    scanf("%s", Media);

    // Create .checkfile
    char *MediaPath = AddDev(Media);
    char CheckFile[11] = "/.checkfile";
    char *CheckFilePath = CombS(MediaPath, CheckFile);
    printf("%s\n", CheckFilePath);

    if (access(MediaPath, F_OK) == 0)
    {
        for (int i=0; i < (sizeof(paths)/20); i++){
            printf("\n[*] Backing up %s\n", paths[i]);
        }
    }
    else
    {
        printf("[*] %s was not meant to be backed up to, .checkfile not found\n", MediaPath);
    }

    return 0;
}
