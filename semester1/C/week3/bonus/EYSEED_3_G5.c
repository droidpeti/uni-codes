#include <stdio.h>
#include <math.h>

int main(){
    int num;
    printf("Input the number you'd like to get the prime factorization of: ");
    scanf("%d", &num);

    printf("The prime factors of %d are: ", num);
    
    while(num % 2 == 0){
        printf("2 ");
        num/=2;
    }

    for(int i = 3; i <= sqrt(num); i+=2){
        while(num%i == 0){
            printf("%d ", i);
            num/=i;
        }
    }

    if(num > 2){
        printf("%d ", num);
    }
    printf("\n");

    return 0;
}