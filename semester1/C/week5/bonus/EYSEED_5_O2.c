#include <stdio.h>

int main(){
    char string[256];
    printf("Please input a string: ");
    scanf("%s", string);

    int row_count = 0;

    for(int i = 0; string[i] != '\0'; i++){
        if(string[i] == '\n'){
            row_count++;
        }
    }

    printf("There were %d rows in the string\n", row_count);
    return 0;
}
