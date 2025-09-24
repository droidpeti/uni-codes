#include <stdio.h>

int main(){
    int num;
    printf("Input a number: ");
    scanf("%d", &num);
    printf("%d with reversed bits is: %d\n", num, ~num);
    return 0;
}