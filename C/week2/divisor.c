#include <stdio.h>

int main(){
	int num;
	printf("Please input the number you want to see the divisors of: ");
	scanf("%d", &num);

	for(int i = 1; i <= num; i++){
		if(num%i == 0){
			printf("%d\n", i);
		}
	}
	
	return 0;
}
