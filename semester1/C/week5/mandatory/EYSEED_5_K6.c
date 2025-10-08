#include <stdio.h>

int main(){
    int numbers[] = {1,2,3,4,5,6,7,8};
    double weights[] = {10.5,10.98,5.4,1.12,1,7,8,9,4};
    double sum = 0;
    for(int i = 0; i < (int)(sizeof(numbers)/sizeof(numbers[0])); i++){
        sum += ((double)numbers[i])*weights[i];
    }
    printf("The weighted average is: %lf\n", sum/((double)(sizeof(numbers)/sizeof(numbers[0]))));
    return 0;
}
