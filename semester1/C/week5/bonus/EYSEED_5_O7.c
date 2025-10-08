#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int comp(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

int get_median(int array[], int length){
    qsort(array, length, sizeof(array[0]), comp);
    if(length&1){
        return array[length/2];
    }
    return (array[(length/2)-1] + array[(length/2)]) / 2;
}

int rng(int min_value, int max_value){
    return rand() % (max_value - min_value + 1) + min_value;
}

void fill_array(int array[], int length){
    for(int i = 0; i < length; i++){
        array[i] = rng(0, 999);
    }
}

int main(){
    srand(time(NULL));
    int array_length = 101;
    int array[array_length];
    fill_array(array, array_length);
    printf("Median of the first array is: %d\n", get_median(array, array_length));

    int array2_length = 100;
    int array2[array2_length];
    fill_array(array2, array2_length);
    printf("Median of the second array is: %d\n", get_median(array2, array2_length));

    return 0;
}
