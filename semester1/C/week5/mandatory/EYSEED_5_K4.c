#include <stdio.h>

int get_min(int array[], int length){
    int min = array[0];
    for(int i = 0; i < length; i++){
        if(array[i] < min){
            min = array[i];
        }
    }
    return min;
}

int main(){
    int array[] = {10,20,30,900,40};
    int min = get_min(array, (int)(sizeof(array)/sizeof(array[0])));

    int count_without_min = 0;
    for(int i = 0; i < (int)(sizeof(array)/sizeof(array[0])); i++){
        if(array[i] != min){
            count_without_min++;
        }
    }
    
    int array2[count_without_min];
    int cur_index = 0;
    for(int i = 0; i < (int)(sizeof(array)/sizeof(array[0])); i++){
        if(array[i] != min){
            array2[cur_index++] = array[i];
        }
    }

    int min_2nd = get_min(array2,count_without_min);

    printf("The second smallest value is: %d\n", min_2nd);
    
    return 0;
}