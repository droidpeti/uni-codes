#include <stdio.h>

long fact(long num){
    static int counter = 0;
    if(num < 1){
        printf("This function has been called with not valid parameters %d times\n", ++counter);
    }
    if(num <= 1){
        return 1;
    }
    return num * fact(num-1);
}

int main(){
    fact(0);
    fact(1);
    fact(2);
    fact(-3);
    return 0;
}
