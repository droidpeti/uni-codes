#include <stdio.h>
#include "my_utils.h"

int main(){
    int a = 10;
    int b = 20;

    int *max_ptr = max(&a, &b);
    printf("The pointer is pointing to this value: %d\n", *max_ptr);
    return 0;
}
