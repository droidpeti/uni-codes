#include <stdio.h>

int main(){
    int year;
    printf("Please enter a year: ");
    scanf("%d", &year);

    printf("%d %s\n", year, ((year % 4 == 0) && year % 100 != 0) || (year % 400 == 0) ? "is a leap year!" : "is not a leap year");

    return 0;
}