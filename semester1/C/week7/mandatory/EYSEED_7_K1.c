#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int main() {
    int capacity = 16; 
    int index = 0;
    char *hex_values = (char *)malloc(capacity * sizeof(char));
    if (hex_values == NULL) {
        printf("Memory Allocation Failed\n");
        exit(1);
    }

    printf("Enter hexadecimal values (0-F). Enter EOF (Ctrl+D on Linux/macOS, Ctrl+Z on Windows) to stop.\n");
    int input;
    while ((input = getchar()) != EOF) { 
        input = toupper(input);
        if (isxdigit(input)) {
            if (index + 1 >= capacity) {
                capacity *= 2;
                char *temp = (char *)realloc(hex_values, capacity * sizeof(char));
                if (temp == NULL) {
                    printf("Memory Re-allocation Failed\n");
                    free(hex_values);
                    exit(1);
                }
                hex_values = temp;
            }
            hex_values[index] = (char)input;
            index++;
        }
    }

    hex_values[index] = '\0';
    printf("\nFinished input.\n");
    printf("Hex values: %s\n", hex_values);
    printf("Converted to decimal: %ld\n", strtol(hex_values, NULL, 16));
    free(hex_values);
    return 0;
}
