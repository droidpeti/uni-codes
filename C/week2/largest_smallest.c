#include <stdio.h>
#include <limits.h>

int main(){
	int num = INT_MAX;
	printf("It takes up %zd bytes\n", sizeof(num));
	printf("It's maximum value is %d\n", num);
	printf("It's minimum value is %d\n", num+1);
	printf("Their average is: %d\n", ((num)+(num+1))/2);
	return 0;
}
