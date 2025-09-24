#include <stdio.h>

int main(){
	printf("Fahrenheit\t\tCelsius\n");
	for(int i = -20; i <= 200; i+=10){
		printf("%d\t\t\t%f\n", i, (i-32)/1.8);
	}
	return 0;
}
