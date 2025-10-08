#include <stdio.h>

int main(){
    int numbers[] = {1,2,3,4,5,6,7,8};
    int sum = 0;
    for(int i = 0; i < (int)(sizeof(numbers)/sizeof(numbers[0])); i++){
        sum += numbers[i];
    }
    printf("the sum is: %d\n", sum);
    return 0;
}