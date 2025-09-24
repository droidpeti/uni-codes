#include <stdio.h>

int main(){
    int date;
    printf("Please input a whole number, which represents a date in this format (YYYYMMDD): ");
    scanf("%d", &date);
    int year = date / 10000;
    int month = (date / 100) % 100;
    int day = date % 100;
    printf("%d in DD-MM-YYYY format: %d-%d-%d\n", date, day, month, year);
    return 0;
}