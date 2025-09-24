#include <stdio.h>
#include <math.h>

int main(){
    int num1;
    int num2;

    printf("Input the first number: ");
    scanf("%d", &num1);
    printf("Input the second number: ");
    scanf("%d", &num2);

    printf("%d^%d = %lf\n", num1, num2, pow(num1,num2));
    printf("%d^%d = %lf\n", num2, num1, pow(num2,num1));
    return 0;
}