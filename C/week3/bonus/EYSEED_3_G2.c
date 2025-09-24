#include <stdio.h>

int main(){
    int num;

    printf("Please input a number: ");
    scanf("%d", &num);

    printf("%d is an %s number\n", num, num&1?"odd":"even");
    return 0 ;
}