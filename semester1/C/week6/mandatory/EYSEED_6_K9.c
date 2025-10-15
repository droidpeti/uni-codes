#include <stdio.h>

int main(){
    int num;
    printf("Please input a whole number: ");
    scanf("%d", &num);
    //The & operator is needed, because the scanf function requires the memory address of the variable, not the variable itself
    return 0;
}