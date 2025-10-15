#include <stdio.h>

int main(){
    int num = 10;
    int num2 = 15;
    int *ptr = &num;
    int **ptr2 = &ptr;

    **ptr2 = num2;
    **ptr2 = 20;

    printf("%d\n", *ptr);

    return 0;
}
