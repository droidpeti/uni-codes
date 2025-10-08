#include <stdio.h>

int main(){
    int array[] = {0,10,20,100,90,89};
    int max = array[0];
    int max_index = 0;
    int min = array[0];
    int min_index = 0;
    
    printf("Original array: ");

    //I assume there can only be a min and max value
    for(int i = 0; i < (int)(sizeof(array)/(sizeof(array[0])));i++){
        if(array[i] < min){
            min = array[i];
            min_index = i;
        }
        if(array[i] > max){
            max = array[i];
            max_index = i;
        }
        printf("%d ", array[i]);
    }

    array[max_index] = min;
    array[min_index] = max;

    printf("\nModified array: ");
    for(int i = 0; i < (int)(sizeof(array)/(sizeof(array[0])));i++){
        printf("%d ", array[i]);
    }
    printf("\n");

    return 0;
}
