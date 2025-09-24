#include <stdio.h>
#include <ctype.h>

int main(){
    char unit;
    float amount;
    printf("Input the unit you want to convert (C/F): ");
    scanf("%c", &unit);
    unit = toupper(unit);
    if(unit == 'C'){
        printf("\nConvert Celsius to Fahrenheit: ");
        scanf("%f", &amount);
        float fahrenheit = amount * 9.0 / 5 + 32;
        printf("\n%fF˚\n", fahrenheit);
    }
    else if(unit == 'F'){
        printf("\nConvert Fahrenheit to Celsius: ");
        scanf("%f", &amount);
        float celsius = (amount - 32) / (9.0/5);
        printf("\n%fC˚\n", celsius);
    }
    else{
        printf("\nIncorrect unit\n");
    }
    return 0;
}
