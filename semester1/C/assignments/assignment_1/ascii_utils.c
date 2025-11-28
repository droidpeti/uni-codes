#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "ascii_utils.h"

void write_ascii_word(char* word, int count, char* file_name){
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Error! File with name: %s not found!\n", file_name);
        return;
    }

    //This only works for row amounts for a single ascii art smaller than 10!
    //short row_count = (short)fgetc(fptr) - 48;
    char buff[4];
    fgets(buff, sizeof(buff), fptr);
    const short row_count = (short)atoi(buff);

    //26 letters

    for(int i = 0; i < row_count; i++){
        for(int j = 0; j < count; j++){
            // -96
            short char_idx = (short)(word[j] - 96);
            int row_to_write = char_idx * row_count + i + 1;
            int k = 0;

            while (1) {
                char buff2[20];
                fgets(buff2, sizeof(buff2), fptr); 
                if(row_to_write == k++)
                {
                    printf("%s", buff2);
                    break;
                }
            }
        }
        printf("\n");
    }
    fclose(fptr);
}
