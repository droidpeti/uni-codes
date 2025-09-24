#include <stdio.h>

int calc(int num1, int num2, char operator){
    int value;
    switch (operator)
    {
        case '+':
            value = num1+num2;
            break;
        case '-':
            value = num1 - num2;
            break;
        case '*':
            value = num1 * num2; 
            break;
        case '/':
            value = num1 / num2;
            break;
        default:
            value = 0;
            break;
    }
    return value;
}

int main(){
    int num1;
    int num2;

    printf("Please input the first number: ");
    scanf("%d", &num1);

    printf("Please input the second number: ");
    scanf("%d", &num2);

    char operators[] = {'+','-','*','/'};

    for(int i = 0; i < sizeof(operators); i++){
        printf("%d %c %d = %d\n", num1, operators[i], num2, calc(num1,num2,operators[i]));
    }
    return 0;
}
