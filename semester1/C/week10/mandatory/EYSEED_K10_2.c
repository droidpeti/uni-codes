#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(){
    const int amount = 5;
    char *words[amount];
    for(int i = 0; i < amount; i++){
        printf("Please enter word #%d: ", i+1);
        int c;
        size_t len = 0;
        size_t capacity = 1;
        char *str = malloc(capacity);
        if(!str){
            printf("Memory allocation failed!");
            return 1;
        }
        while((c = getchar()) != '\n' && c != EOF){
            str[len++] = (char)c;
            capacity++;
            char *temp = realloc(str, capacity);
            if(!temp){
                free(str);
                return 1;
            }
            str = temp;
        }
        str[len] = '\0';
        words[i] = str;
    }
    printf("\n");
    
    for(int i = 0; i < amount; i++){
        printf("%s\n", words[amount-(i+1)]);
    }

    for(int i = 0; i < amount; i++){
        free(words[i]);
    }

    return 0;
}
