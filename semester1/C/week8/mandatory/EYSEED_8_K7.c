#include <stdio.h>

/*
void func(int a, int a){

}
duplicate parameter name
EYSEED_8_K7.c:4:22: error: redefinition of parameter ‘a’
    4 | void func(int a, int a){

You can't do this
*/

int main(){
    printf("You can't use two parameters with the same name when declaring or defining a function\n");
    return 0;
}