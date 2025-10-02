#include <stdio.h>
#include <stdbool.h>

int main(){
    int num_int;
    int num_int_arr[5];
    int *num_int_ptr = &num_int;
    
    long int num_long;
    long int num_long_arr[5];
    long int *num_long_ptr = &num_long;
    
    unsigned int num_uint;
    unsigned int num_uint_arr[5];
    unsigned int *num_uint_ptr = &num_uint;
    
    unsigned long int num_ulong;
    unsigned long int num_ulong_arr[5];
    unsigned long int *num_ulong_ptr = &num_ulong;
    
    char letter;
    char letter_arr[5];
    char *letter_ptr = &letter;
    
    bool boolean;
    bool boolean_arr[5];
    bool *boolean_ptr = &boolean;
    
    float num_float;
    float num_float_arr[5];
    float *num_float_ptr = &num_float;
    
    double num_double;
    double num_double_arr[5];
    double *num_double_ptr = &num_double;
    
    long double num_long_double;
    long double num_long_double_arr[5];
    long double *num_long_double_ptr = &num_long_double;

    printf("int array[5]: %zu bytes\n", sizeof(num_int_arr));
    printf("int pointer: %zu bytes\n", sizeof(num_int_ptr));

    printf("long int array[5]: %zu bytes\n", sizeof(num_long_arr));
    printf("long int pointer: %zu bytes\n", sizeof(num_long_ptr));

    printf("uint array[5]: %zu bytes\n", sizeof(num_uint_arr));
    printf("uint pointer: %zu bytes\n", sizeof(num_uint_ptr));

    printf("ulong array[5]: %zu bytes\n", sizeof(num_ulong_arr));
    printf("ulong pointer: %zu bytes\n", sizeof(num_ulong_ptr));

    printf("char array[5]: %zu bytes\n", sizeof(letter_arr));
    printf("char pointer: %zu bytes\n", sizeof(letter_ptr));

    printf("bool array[5]: %zu bytes\n", sizeof(boolean_arr));
    printf("bool pointer: %zu bytes\n", sizeof(boolean_ptr));

    printf("float array[5]: %zu bytes\n", sizeof(num_float_arr));
    printf("float pointer: %zu bytes\n", sizeof(num_float_ptr));

    printf("double array[5]: %zu bytes\n", sizeof(num_double_arr));
    printf("double pointer: %zu bytes\n", sizeof(num_double_ptr));

    printf("long double array[5]: %zu bytes\n", sizeof(num_long_double_arr));
    printf("long double pointer: %zu bytes\n", sizeof(num_long_double_ptr));
    
    return 0;
}