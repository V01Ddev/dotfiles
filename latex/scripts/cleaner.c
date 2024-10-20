#include <stdlib.h>


int main(){
    system("rm *.gz");
    system("rm *.log");
    system("rm *.toc");
    system("rm *.aux");
    system("rm *.out");
    system("rm *.fl*");
    system("rm *.fd*");

    return 0;
}
