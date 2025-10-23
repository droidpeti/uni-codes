#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(){
    int num;
    printf("Please input an integer with at least 3 digits: ");
    scanf("%d", &num);
    int digits = floor(log10(num)) + 1;
    if(digits < 3){
        printf("Not enough digits!\n");
        return 1;
    }

    char string[digits];
    sprintf(string, "%d", num);

    char helper = string[0];
    string[0] = string[digits-1];
    string[digits-1] = helper;
    char *endptr;

    num = (int)strtol(string,&endptr,10);

    printf("The number with first and last digits swapped: %d\n", num);
    return 0;
}
