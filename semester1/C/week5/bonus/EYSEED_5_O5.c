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
    int numbers[] = {1,2,4,7,9,28,220,284,311};

    for(int i = 0; i < (int)(sizeof(numbers)/sizeof(numbers[0])); i++){
        int num1 = numbers[i];
        for(int j = i + 1; j < (int)(sizeof(numbers)/sizeof(numbers[0])); j++){
            int num2 = numbers[j];
            int num1_divisor_sum = get_divisor_sum(num1);
            int num2_divisor_sum = get_divisor_sum(num2);

            if(num1_divisor_sum == num2 && num2_divisor_sum == num1){
                printf("%d and %d are friendly numbers!\n", num1, num2);
            }
        }
    }
    
    return 0;
}
