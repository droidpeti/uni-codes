#include <stdio.h>

int **function(){
    int num = 10;
    int *num_ptr = &num;
    int **num_ptr_ptr = &num_ptr;
    /*
        EYSEED_6_K7.c: In function ‘function’:
        EYSEED_6_K7.c:7:5: warning: statement with no effect [-Wunused-value]
        7 |     *(num_ptr_ptr);
          |     ^~~~~~~~~~~~~~
          *(num_ptr_ptr);
    */
    return num_ptr_ptr;
}

int main(){
    printf("Address of num_ptr (int*): %p\n", (void *)function()); 
    return 0;
}