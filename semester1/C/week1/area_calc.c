#include <stdio.h>

int main(){
	float a;
	float b;
	float r;
	printf("Input the length of side a of the rectangle: ");
	scanf("%f", &a);
	printf("Input the length of side b of the rectangle: ");
	scanf("%f", &b);
	printf("Input the length of the radius of the circle: ");
	scanf("%f", &r);
	printf("The area of the rectangle is: %f", a*b);
	printf("\nThe area of the circle is: %f\n", r*r*3.1415);
	return 0;
}

