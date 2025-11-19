#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    char **words = NULL; 
    int count = 0;
    
    char buffer[101]; 

    printf("Enter words (Press Ctrl+D to stop):\n");

    while(scanf("%100s", buffer) != EOF) {
        
        count++;

        size_t new_size = count * sizeof(char*);
        
        char **temp = realloc(words, new_size);
        
        if(!temp) {
            printf("Memory allocation failed!\n");
            for(int i = 0; i < count-1; i++) free(words[i]);
            free(words);
            return 1;
        }
        words = temp;

        words[count - 1] = malloc(strlen(buffer) + 1);
        
        if (!words[count - 1]) {
             printf("String allocation failed!\n");
             return 1;
        }
        
        strcpy(words[count - 1], buffer);
    }

    for(int i = 0; i < count; i++) {
        printf("%s\n", words[count - (i + 1)]);
    }

    for(int i = 0; i < count; i++) {
        free(words[i]);
    }
    free(words);

    return 0;
}