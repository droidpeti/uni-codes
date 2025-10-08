#include <stdio.h>

int main(){
    int array[] = {10, 20, 30, 900, 40};
    int max = array[0];
    for(int i = 0; i < (int)(sizeof(array)/sizeof(array[0])); i++){
        if(array[i] > max){
            max = array[i];
        }
    }
    printf("The largest number in the array is: %d\n", max);
    return 0;
}