#include <stdio.h>

int main(){
	char name[10];
	printf("Hello, please tell me your name: ");
	scanf("%s", name);
	printf("Hello, %s!\n", name);
	return 0;
}
