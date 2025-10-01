#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int rng(int min_value, int max_value){
    return rand() % (max_value - min_value + 1) + min_value;
}

int main(){
    srand(time(NULL));
    int min_value = 1;
    int max_value;
    char difficulty;
    // e 1-10
    // m 1-100
    // h 1-10000
    printf("Difficuly selection, e is for easy, m is for medium, h is for hard\n");
    printf("Please select difficulty (e, m, h): ");
    scanf("%c", &difficulty);

    switch(difficulty){
        case 'e':
            max_value = 10;
            break;
        case 'm':
            max_value = 100;
            break;
        case 'h':
            max_value = 10000;
            break;
        default:
            printf("Invalid input!\n");
            exit(1);
            break;
    }

    int random_num = rng(min_value,max_value);
    int guess;
    int guess_count = 0;

    while(guess != random_num){
        printf("Please take a guess between %d and %d: ", min_value, max_value);
        scanf("%d", &guess);
        printf("The number is %s %d\n", guess != random_num ? (guess < random_num ? "larger than" : "smaller than") : "equal to", guess);
        guess_count++;
    }

    printf("You guessed the number in %d guesses, ", guess_count);
    printf("that is ");
    if(guess_count < 4){
        printf("amazing!");
    }
    else if(guess_count < 8){
        printf("good!");
    }
    else{
        printf("O.K.!");
    }
    printf("\n");
    return 0;
}