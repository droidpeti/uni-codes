#include <stdio.h>

int is_leap_year(int year) {
    if (year % 400 == 0)
    {
        return 1;
    }
    if (year % 100 == 0)
    {
        return 0;
    }
    if (year % 4 == 0){
        return 1;
    } 
    return 0;
}

int main(){
    int date;
    printf("Input a number which represents the days passed since 1800-01-01: ");
    scanf("%d", &date);

    //date = 0 -> 1800-01-01
    //date = 1 -> 1800-01-02

    int year = 1800;
    int month = 1;
    int day = 1;

    int remaining_days = date;

    day += remaining_days;
    remaining_days = 0;

    while (1) {
        int days_in_year = is_leap_year(year) ? 366 : 365;
        if (day <= days_in_year) {
            break;
        }
        day -= days_in_year;
        year++;
    }

    int days_in_month[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (is_leap_year(year)) {
        days_in_month[1] = 29;
    }

    while (1) {
        if (day <= days_in_month[month]) {
            break;
        }
        day -= days_in_month[month];
        month++;
    }

    printf("The date is: %d-%02d-%02d\n", year, month, day);

    return 0;
}