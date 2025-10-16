#include <stdio.h>

int *max(int array[], int count){
    int *max_ptr = &array[0];
    for(int i = 0; i < count; i++){
        if(array[i] > *max_ptr){
            max_ptr = &array[i];
        }
    }
    return max_ptr;
    //We can directly change the value of the element max pointer points to globally here.
}

int main(){
    int num = 9;
    int *max_element = max(&num, 1);
    printf("The max value is: %d\n", *max_element);
    return 0;
}
