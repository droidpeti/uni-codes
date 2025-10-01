#include <stdio.h>

int includes(char item, char array[], int size){
    for(int i = 0; i < size; i++){
        if(array[i] == item){
            return 1;
        }
    }
    return 0;
}

double calc(double num1, char operator, double num2){
    double value;
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
    double num1;
    char operator;
    double num2;

    char valid_operators[4] = {'+', '-', '*', '/'};
    int num_operators = sizeof(valid_operators) / sizeof(valid_operators[0]);

    printf("Please input a number: ");
    scanf("%lf", &num1);
    printf("Please input the operator you would like to run\n");
    do{
        printf("Valid operators ( ");
        for(int i = 0; i < num_operators; i++){
            printf("%c,", valid_operators[i]);
        }
        printf("\b ): ");
        scanf(" %c", &operator);
    }while(!includes(operator, valid_operators, num_operators));

    printf("Please input the second number: ");
    scanf("%lf", &num2);

    printf("%lf %c %lf = %lf\n", num1, operator, num2, calc(num1,operator,num2));

    return 0;
}