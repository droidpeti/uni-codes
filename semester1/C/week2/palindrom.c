#include <stdio.h>

int main(){
	int num;
	int num_reverse = 0;
	int temp;
	int remainder;
	printf("Enter the number you want to see is a palindrome: ");
	scanf("%d", &num);
	temp = num;
	
	while(temp != 0){
		remainder = temp%10;
		num_reverse = num_reverse * 10 + remainder;
		temp/=10;
	}

	if(num == num_reverse){
		printf("palindrome");
	}
	else{
		printf("not a palindrome");
	}
	printf("\n");
	return 0;
}
