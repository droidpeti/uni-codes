#include <stdio.h>

void func(int num1, int num2);

void func(int a, int b){
    printf("%d * %d = %d\n", a, b, a*b);
}
// defining and declaring a function like this can be beneficial for the code's structure in larger projects

int main(){
    func(10,20);
    return 0;
}
