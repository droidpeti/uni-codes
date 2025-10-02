#include <stdio.h>
#include <math.h>

int is_prime(int num) {
    if (num <= 1) {
        return 0; 
    }

    if (num == 2) {
        return 1;
    }

    if (num % 2 == 0) {
        return 0;
    }

    for (int i = 3; i <= sqrt(num); i += 2) {
        if (num % i == 0) {
            return 0;
        }
    }

    return 1;
}

int main(){
    int num1;
    int num2;
    printf("You will need to enter 2 numbers, and the first one has to be smaller than or equal to the second one\n");

    printf("Please input the first number: ");
    scanf("%d", &num1);
    printf("Please input the second number: ");
    scanf("%d", &num2);

    if(num1 > num2){
        printf("The second number can't be smaller than the first one\n");
        return 0;
    }

    for(int i = num1; i <= num2; i++){
        if(is_prime(i)){
            printf("%d\n", i);
        }
    }
    return 0;
}