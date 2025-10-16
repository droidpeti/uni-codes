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
    int count = 6;
    int array[6] = {10, 3, 4, 56, 9, 8};
    int *max_element = max(array, count);
    int count_half = count/2;
    int *max_element_half = max(array,count_half);
    printf("The max value is: %d\n", *max_element);
    printf("The max value of the first half is: %d\n", *max_element_half);
    return 0;
}
