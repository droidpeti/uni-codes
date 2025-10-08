#include <stdio.h>

int main(){
    int numbers[] = {1,2,3,4,5,6,7,8};
    int weights[] = {10,10,5,1,1,7,8,9,4};
    int sum = 0;
    for(int i = 0; i < (int)(sizeof(numbers)/sizeof(numbers[0])); i++){
        sum += numbers[i]*weights[i];
    }
    printf("The weighted sum is: %d\n", sum);
    return 0;
}
