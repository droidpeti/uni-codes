#include <stdio.h>

int get_divisor_sum(int num){
    int sum = 0;
    for(int i = 1; i < num; i++){
        if(num % i == 0){
            sum += i;
        }
    }
    return sum;
}

int main(){
    int num1;
    int num2;
    printf("Please input the first number: ");
    scanf("%d", &num1);
    printf("Please input the second number: ");
    scanf("%d", &num2);

    int num1_divisor_sum = get_divisor_sum(num1);
    int num2_divisor_sum = get_divisor_sum(num2);

    if(num1_divisor_sum == num2 && num2_divisor_sum == num1){
        printf("%d and %d are friendly numbers!", num1, num2);
    }
    else{
        printf("%d and %d are not friendly numbers", num1, num2);
    }
    printf("\n");
    
    return 0;
}