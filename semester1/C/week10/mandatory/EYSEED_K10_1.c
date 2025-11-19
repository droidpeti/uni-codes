#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(){
    printf("Please enter a string of maximum length 20: ");
    char text[21];
    scanf("%20s", text);
    char *copy = (char *)malloc(strlen(text)+1);
    if (copy == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    strcpy(copy, text);
    printf("The length of %s is: %zu\n", copy, strlen(copy));
    free(copy);
    return 0;
}
