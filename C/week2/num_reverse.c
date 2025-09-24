#include <stdio.h>

int main(){
	int num;
	int num_reverse = 0;
	int remainder;
	printf("Enter the number you want to see reversed: ");
	scanf("%d", &num);

	while(num != 0){
		remainder = num%10;
		num_reverse = num_reverse * 10 + remainder;
		num/=10;
	}

	printf("%d\n", num_reverse);
	return 0;
}
