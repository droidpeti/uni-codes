#include <stdio.h>

int *product(int a, int b){
    int sum = a + b;
    int *sum_ptr = &sum;
    return sum_ptr;
}

int main(){
    int a = 5;
    int b = 10;
    printf("%d\n", *product(a,b));
    return 0;
}