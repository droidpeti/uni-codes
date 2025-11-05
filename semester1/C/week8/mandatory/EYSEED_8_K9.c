#include <stdio.h>
#include "my_utils.h"

int main(){
    int num1 = 10;
    int num2 = 20;
    printf("The value of num1: %d\nThe value of num2: %d\n", num1, num2);
    swap(&num1,&num2);
    printf("The value of num1: %d\nThe value of num2: %d\n", num1, num2);
    return 0;
}
