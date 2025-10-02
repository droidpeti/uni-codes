#include <stdio.h>
#include <math.h>

int main(){
    float a;
    float b;
    
    printf("Input the length of the base side of the triangle: ");
    scanf("%f", &a);
    printf("Input the length of the remaining 2 sides: ");
    scanf("%f", &b);

    if (2 * b <= a) {
        printf("The sides can't form a triangle\n");
        return 0;
    }

    float perimeter = a+b*2;
    printf("The perimeter of the triangle is: %f\n", perimeter);

    float s = perimeter/2;
    printf("The area of the triangle is: %f\n", sqrt(s*(s-a)*(s-b)*(s-b)));

    return 0;
}