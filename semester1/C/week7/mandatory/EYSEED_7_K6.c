#include <stdio.h>
#include <time.h>
#include <stdlib.h>

double randfrom(double min, double max) 
{
    double range = (max - min); 
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

void fill_array(double *array, int count){
    const double min_val = 0.0;
    const double max_val = 100.0;
    for(int i = 0; i < count; i++){
        array[i] = randfrom(min_val, max_val);
    }
}

int main(){
    srand(time(NULL));
    const int count = 100;
    double array[count];
    fill_array(array, count);

    int valid_item_count = 0;
    for(int i = 0; i < count; i++){
        if(array[i] > 50.0){
            valid_item_count++;
        }
    }

    printf("Values larger than 50: %d\n", valid_item_count);
    return 0;
}
