#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int roll_dice(){
    int max_value = 6;
    return (rand() % max_value) + 1;
}

int main(){
    srand(time(NULL));

    for(int i = 0; i < 10; i++){
        printf("Dice rolled: %d\n", roll_dice());
    }

    return 0;
}