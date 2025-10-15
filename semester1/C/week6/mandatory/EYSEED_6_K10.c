#include <stdio.h>

void smaller_index(int *ptr, int *qtr){
    if(ptr < qtr){
        printf("Pointer number 1: %p points to the smaller index.\n", (void *)ptr);
        return;
    }
    else if(ptr > qtr){
        printf("Pointer number 2: %p points to the smaller index.\n", (void *)qtr);
        return;
    }
    printf("Pointer number 1 %p and pointer number two %p point to the same index\n", (void *)ptr, (void *)qtr);
    return;
}

int main(){
    int array[] = {1,2,3,4,5,6,7,8,9,10};
    int *ptr = &array[3];
    int *qtr = &array[7];
    smaller_index(ptr, qtr);
    return 0;
}