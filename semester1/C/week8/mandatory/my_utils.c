#include <stdio.h>
#include "my_utils.h"

void static_increment(){
    static int num = 0;
    printf("%d\n", ++num);
}

void swap(int *a, int *b){
    int c = *a;
    *a = *b;
    *b = c;
}

int* max(int* a, int* b){
    if(*a > *b){
        return a;
    }
    return b;
}
