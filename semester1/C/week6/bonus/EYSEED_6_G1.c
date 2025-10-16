#include <stdio.h>

int *return_ptr(int array[]){
    return array;
}

int main(){
    int array[] = {1, 2, 3, 4, 5};
    int *ptr = array;
    printf("The pointer points to: %p\n", (void *)ptr);
    int array2[] = {6, 7, 8, 9, 0};
    ptr = return_ptr(array2);
    printf("The pointer points to: %p\n", (void *)ptr);
    return 0;
}
