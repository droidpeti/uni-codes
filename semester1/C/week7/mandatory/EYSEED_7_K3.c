#include <stdio.h>

unsigned int sum(unsigned int n){
    return (n*(n+1))/2;
}

int main(){
    unsigned int num;
    printf("Please input a positive integer: ");
    scanf("%u", &num);

    printf("The sum of all numbers from 1 to %u is: %u\n", num, sum(num));

    return 0;
}
