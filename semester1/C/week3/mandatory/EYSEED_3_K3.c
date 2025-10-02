#include <stdio.h>

int main(){
	float r;
	printf("Input the length of the radius of the circle: ");
	scanf("%f", &r);
    printf("The diameter of the circle is: %f", r*2);
    printf("\nThe perimeter of the circle is: %f", r*2*3.1415);
	printf("\nThe area of the circle is: %f\n", r*r*3.1415);
	return 0;
}
