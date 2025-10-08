#include <stdio.h>

int main(){
    int array[10];
    for(int i = 0; i < (int)(sizeof(array)/sizeof(array[0])); i++){
        array[i] = 0;
        printf("%d\n", array[i]);
    }
    return 0;
}
