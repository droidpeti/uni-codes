#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *reverse(char base[]){
    int count = strlen(base);
    char *str = malloc(count + 1);
    if(!str){
        printf("Memory allocation failed!");
        return NULL;
    }
    for(int i = 0; i < count; i++){
        str[i] = base[count-(i+1)];
    }
    str[count] = '\0';
    return str;
}

int main(){

    printf("Please enter a string: ");
    char string[21];
    scanf("%20s", string);
    char *rev = reverse(string);
    printf("%s\n", rev);
    free(rev);
    return 0;
}
