#include <stdio.h>

int main(){
    int num;
    int bit_index;

    printf("Input a number: ");
    scanf("%d", &num);

    printf("Input the bit's index you'd like to negate: ");
    scanf("%d", &bit_index);
    if(bit_index < 0){
        printf("The bit's index can't be smaller than zero\n");
        return 0;
    }

    printf("%d with it's bit at index %d inversed: %d\n", num, bit_index, num ^ (1 << bit_index));

    return 0;
}