#include <stdio.h>
#include <stdlib.h>



int main(){

    char BackupType;

    printf("[*] Please ensure backup media is mounted \n");
    printf("[*] Quick or Fast backup? q or f --> ");
    scanf("%c", &BackupType);
        
    system("lsblk");

    printf("[*] The backup media (without the /dev/) --> ");
    scanf("%s", &Media);

    return 0;
}
