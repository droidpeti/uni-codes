#include <stdio.h>

int return_value(int num){
    //here only local copies of the parameters are worked with.
    return num+10;
}

void override_value(int *num){
    //We can directly change the values of the parameters globally like this.
    *num += 10;
}

int main(){
    int number = 20;
    number = return_value(number);
    printf("The value of number is: %d\n", number);

    number = 20;
    override_value(&number);
    printf("The value of number is: %d\n", number);

    return 0;
}
