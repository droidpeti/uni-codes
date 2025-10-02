#include <stdio.h>

int main(){
    float a;
    float b;

    printf("Input the length of side a of the rectangle: ");
    scanf("%f", &a);
    printf("Input the length of side b of the rectangle: ");
    scanf("%f", &b);

    printf("The perimeter of the rectangle: %f\n", 2*a+2*b);
    printf("The area of the rectangle: %f\n", a*b);
    return 0;
}