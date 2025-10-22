#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int contains(char needle, char haystack[], int count){
    for(int i = 0; i < count; i++){
        if(haystack[i] == needle){
            return 1;
        }
    }
    return 0;
}

int main(){
    char accepted_chars[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    int accepted_count = (int)(sizeof(accepted_chars) / sizeof(accepted_chars[0]));

    int size = 1;
    char *hex_values = (char *)malloc(size * sizeof(char));

    if(hex_values == NULL){
        printf("Memory Allocation Failed\n");
        exit(1);
    }

    hex_values[0] = '\0';

    printf("Enter hexadecimal values (0-F). Enter an invalid character to stop.\n");

    while(1){
        char input;
        printf("\nPlease input the next hexadecimal value (0-F): ");
        if (scanf(" %c", &input) != 1) {
            break;
        }
        input = toupper(input);

        if(contains(input, accepted_chars, accepted_count)){
            size++;
            hex_values = (char *)realloc(hex_values, size);
            if(hex_values == NULL){
                printf("Memory Allocation Failed\n");
                free(hex_values);
                exit(1);
            }

            hex_values[size-2] = input;
            hex_values[size-1] = '\0';
        }
        else{
            break;
        }
    }

    printf("\nFinished input.\n");
    printf("Hex values: %s\n", hex_values);
    free(hex_values);

    return 0;
}
