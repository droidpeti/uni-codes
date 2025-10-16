#include <stdio.h>

#define COUNT_X 3
#define COUNT_Y 3

int array_sum(int* array, int count){
    int sum = 0;
    for(int i = 0; i < count; i++){
        sum+=*(array+i);
    }
    return sum;
}

int main(){
    int matrix[COUNT_X][COUNT_Y] = {
        {1,2,3},
        {4,5,6},
        {7,8,9}
    };    
    int sum = array_sum((int *)matrix, COUNT_X * COUNT_Y);
    //It treats it just like a regular array
    
    printf("Sum: %d\n", sum);
    return 0;
}