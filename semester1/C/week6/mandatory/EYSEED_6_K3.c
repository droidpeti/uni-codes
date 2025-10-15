#include <stdio.h>

int main(){
    //a pointer can not point to itself
    int num;
    double big_num;
    char letter;
    int *num_ptr = &num;
    double *big_num_ptr = &big_num;
    char *letter_ptr = &letter;
    printf("Int ptr size: %zu bytes\nDouble ptr size: %zu bytes\nChar ptr size: %zu bytes\n", sizeof(num_ptr), sizeof(big_num_ptr), sizeof(letter_ptr));
    //on 64 bit CPUs all pointers are 8 bytes
    return 0;
}
