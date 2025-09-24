#include <stdio.h>

int main(){
    int num1;
    int num2;

    printf("Please input the first number: ");
    scanf("%d", &num1);

    printf("Please input the first number: ");
    scanf("%d", &num2);
    
    num1 += num2;
    num2 = num1 - num2;
    num1 -= num2;

    printf("num1: %d\nnum2: %d\n", num1, num2);

    return 0;
}