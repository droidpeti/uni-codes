#include <stdio.h>

// you can't calculate the count inside the function, have to pass it
double array_sum(double* array, int count){
    double sum = 0;
    for(int i = 0; i < count; i++){
        sum+=array[i];
    }
    return sum;
}

double array_sum2(double* array, int count){
    double sum = 0;
    for(int i = 0; i < count; i++){
        sum+=*(array+i);
    }
    return sum;
}

int main(){
    double array[] = {10.7, 8.0, 7.6, 4.3};
    printf("Result of first function: %lf\nResult of second function: %lf\n",
        array_sum(array, (int)(sizeof(array)/(sizeof(array[0])))),
        array_sum2(array, (int)(sizeof(array)/(sizeof(array[0]))))
    );
    return 0;
}