#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int rng(int min_value, int max_value){
    return rand() % (max_value - min_value + 1) + min_value;
}

int main(){
    srand(time(NULL));
    int min_value = 1;
    int max_value = 100;

    int random_num = rng(min_value,max_value);
    int guess;

    while(guess != random_num){
        printf("Please take a guess between %d and %d: ", min_value, max_value);
        scanf("%d", &guess);
        printf("The number is %s %d\n", guess != random_num ? (guess < random_num ? "larger than" : "smaller than") : "equal to", guess);
    }
    return 0;
}
