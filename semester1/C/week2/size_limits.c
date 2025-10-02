#include <stdio.h>
#include <stdbool.h>

int main(){
	int num_int;
	long int  num_long;
	unsigned int num_uint;
	unsigned long int num_ulong;
	char letter;
	bool boolean;
	float num_float;
	double num_double;
	long double num_long_double;

	printf("int: %zu bytes\n", sizeof(num_int));
	printf("long int: %zu bytes\n", sizeof(num_long));
	printf("uint: %zu bytes\n", sizeof(num_uint));
	printf("ulong: %zu bytes\n", sizeof(num_ulong));
	printf("char: %zu bytes\n", sizeof(letter));
	printf("bool %zu bytes\n", sizeof(boolean));
	printf("float: %zu bytes\n", sizeof(num_float));
	printf("double: %zu bytes\n", sizeof(num_double));
	printf("long double: %zu bytes\n", sizeof(num_long_double));
	
	return 0;
}
