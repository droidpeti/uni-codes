#include <stdio.h>
#include <ctype.h>
#include <string.h>

int indexof(char haystack[], char needle, int length){
    for(int i = 0; i < length; i++){
        if(haystack[i] == needle){
            return i;
        }
    }
    return -1;
}

int main(){
    char alphabet[26] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
    char input[255];

    printf("Please input letters from the english alphabet which correspond to a row's/column's number in a spreadsheet: ");
    scanf("%255s", input);
    size_t len = strlen(input);
    int num = 0;

    for(int i = 0; i < (int)len; i++){
        int index = (indexof(alphabet, input[i], (int)strlen(alphabet)))+1;
        if(index == -1){
            printf("Invalid input!\n");
            return 1;
        }
        num = (num*26) + index;
    }

    printf("%s is row/column number %d\n", input, num);

    return 0;
}
