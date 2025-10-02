#include <stdio.h>

int main(){
	int num1;
	int num2;
	int tempNum;
	
	printf("Please enter the first number: ");
	scanf("%d", &num1);
	printf("Please enter the second number: ");
	scanf("%d", &num2);
	//Eukledeszi algoritmus	
	printf("The greatest common divisor of %d and %d is: ", num1, num2);
	
	while(num2 != 0){
		tempNum = num2;
		num2 = num1 % num2;
		num1 = tempNum;
	}
	
	printf("%d\n", num1);
	
	return 0;
}
