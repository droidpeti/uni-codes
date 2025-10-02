#include <stdio.h>

int main(){
	int input_days;
	int years;
	int weeks;
	int days;
	printf("Please input the number of days you want to convert: ");
	scanf("%d", &input_days);
	years = input_days / 365;
	int remaining_days = input_days % 365;
	weeks = remaining_days / 7;
	days = remaining_days % 7;
	printf("%d days is %d years, %d weeks, %d days\n", input_days, years, weeks, days);
	return 0;
}
