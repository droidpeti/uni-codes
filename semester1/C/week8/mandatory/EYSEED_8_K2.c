#include <stdio.h>

void func(){
    int num = 10;
    // you can reach the num variable inside this function
}

int main(){
    // you can't reach num here
    printf("Hello World!\n");
    return 0;
}
