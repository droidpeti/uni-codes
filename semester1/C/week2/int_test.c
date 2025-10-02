#include <stdio.h>

int main(){
	int test;
	printf("%d\n", test);
	printf("Please input a number: ");
	scanf("%d", &test);
	if(test&1){
		printf("This number is odd");
	}
	else{
		printf("This number is even");
	}
	printf("\n");
	if(test > 0){
		printf("This number is positive");
	}
	else if(test < 0){
		printf("This number is negative");
	}
	else{
		printf("This number is zero");
	}
	printf("\n");
	return 0;
}
