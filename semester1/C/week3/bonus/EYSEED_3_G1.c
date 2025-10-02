#include <stdio.h>

int main(){
    int num1 = 5;
    int num2 = 6;

    printf("%d & %d = %d\n", num1, num2, num1&num2);
    printf("%d | %d = %d\n", num1, num2, num1|num2);
    printf("%d ^ %d = %d\n", num1, num2, num1^num2);
    printf("%d << %d = %d\n", num1, num2, num1<<num2);
    printf("%d >> %d = %d\n", num1, num2, num1>>num2);
    printf("~%d = %d\n", num1, ~num1);
    return 0;
}