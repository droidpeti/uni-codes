#include <stdio.h>

int main(){
    /*
        void swap(int *a, int *b){
        int c = *a;
        *a = *b;
        *b = c;
    }
    */
    int num1 = 10;
    int num2 = 20;
    printf("The value of num1: %d\nThe value of num2: %d\n", num1, num2);
    //swap(&num1,&num2);
    //printf("The value of num1: %d\nThe value of num2: %d\n", num1, num2);
    return 0;

    //nested functions are not allowed since ISO C99 and later

    //gcc successfully compiles this code, clang does not

    /*  
    gcc warning:

        EYSEED_8_K11.c: In function ‘main’:
        EYSEED_8_K11.c:6:5: warning: ISO C forbids nested functions [-Wpedantic]
        6 |     void swap(int *a, int *b){
          |     ^~~~

    clang error:
    EYSEED_8_K11.c:6:30: error: function definition is not allowed here
        6 |     void swap(int *a, int *b){
          |                              ^
    EYSEED_8_K11.c:15:5: error: call to undeclared function 'swap'; ISO C99 and later do not support implicit function declarations
        [-Wimplicit-function-declaration]
    15 |     swap(&num1,&num2);
       |     ^
    2 errors generated.
    */
}
