#include <stdio.h>
#include <stdlib.h>

int main() {
    int *numbers = NULL;
    int count = 0;
    int num;

    printf("Enter numbers, Press Ctrl+D to stop):\n");

    while(scanf("%d", &num) != EOF) {
        
        count++;

        size_t new_size = count * sizeof(int);
        
        int *temp = realloc(numbers, new_size);
        
        if(!temp) {
            printf("Memory allocation failed!\n");
            free(numbers);
            return 1;
        }
        numbers = temp;

        numbers[count - 1] = num;
    }

    for(int i = 0; i < count; i++) {
        printf("%d\n", numbers[count - (i + 1)]);
    }

    free(numbers);

    return 0;
}