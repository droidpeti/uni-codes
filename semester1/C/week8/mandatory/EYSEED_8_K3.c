#include <stdio.h>

void func(){
    int num = 10;
    // you can reach the num variable inside this function
    if(num == 10){
        printf("The value of num is: %d\n", num);
    }
    else if(num == 11){
        printf("The value of num is: %d\n", num);
    }
    else{
        printf("The value of num is: %d\n", num);
    }

    // you can reach the num variable in all blocks inside this function
}

int main(){
    // you can't reach num here
    printf("Hello World!\n");
    func();
    return 0;
}
