#include <stdio.h>

int main(){
    char string[255];
    printf("Please input a string: ");
    scanf("%s", string);

    int count = 0;

    for(int i = 0; i < (int)(sizeof(string)); i++){
        if(string[i] == '\0'){
            break;
        }
        count++;
    }

    printf("The length of the string is %d\n", count);
    return 0;
}
