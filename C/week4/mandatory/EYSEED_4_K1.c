#include <stdio.h>
#include <stdbool.h>

int main(){
    int num;
    long int num2;
    unsigned int num3;
    unsigned long int num4;
    char letter;
    bool binary;
    double num5;
    long double num6;

    printf("Size of int: %zu bytes\n", sizeof(num));
    printf("Size of long int: %zu bytes\n", sizeof(num2));
    printf("Size of unsigned int: %zu bytes\n", sizeof(num3));
    printf("Size of unsigned long int: %zu bytes\n", sizeof(num4));
    printf("Size of char: %zu bytes\n", sizeof(letter));
    printf("Size of bool: %zu bytes\n", sizeof(binary));
    printf("Size of double: %zu bytes\n", sizeof(num5));
    printf("Size of long double: %zu bytes\n", sizeof(num6));

    return 0;
}