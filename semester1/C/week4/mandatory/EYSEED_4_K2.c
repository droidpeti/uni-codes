#include <stdio.h>

int main(){
    int a = 1;
    int b = 2;
    int c = 3;

    // a < b < c => warning: comparisons like ‘X<=Y<=Z’ do not have their mathematical meaning

    if(a<b && b<c){
        printf("True!\n");
    }
    else{
        printf("False!\n");
    }

    return 0;
}