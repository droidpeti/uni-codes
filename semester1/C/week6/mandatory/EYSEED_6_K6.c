#include <stdio.h>

double array_avg(double *start_ptr, double *end_ptr){
    double sum = 0;
    int count = (int)(end_ptr - start_ptr);
    while(start_ptr < end_ptr){
        sum+=*start_ptr;
        start_ptr++;
    }
    return (sum/((double)count));
}

int main(){
    double array[] = {10.7, 8.0, 7.6, 4.3};
    int count = sizeof(array) / sizeof(array[0]);
    double *start = array;
    double *end = array + count; 
    double total = array_avg(start, end);

    printf("The average is: %lf\n", total);

    return 0;
}