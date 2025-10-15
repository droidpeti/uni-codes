#include <stdio.h>

double array_sum(double *start_ptr, double *end_ptr){
    double sum = 0;
    while(start_ptr < end_ptr){
        sum+=*start_ptr;
        start_ptr++;
    }
    return sum;
}

int main(){
    double array[] = {10.7, 8.0, 7.6, 4.3};
    int count = sizeof(array) / sizeof(array[0]);
    double *start = array;
    double *end = array + count; 
    double total = array_sum(start, end);

    printf("The sum is: %lf\n", total);

    return 0;
}
