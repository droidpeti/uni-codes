#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void reverse(char str[]){
    if (str == NULL) return;

    int length = strlen(str);
    int start = 0;
    int end = length - 1;
    char temp;

    while (start < end) {
        temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
}

int main(){

    printf("Please enter a string: ");
    char string[21];
    scanf("%20s", string);
    reverse(string);
    printf("%s\n", string);
    return 0;
}
