#include <stdio.h>
#include <stdlib.h>
#include "ascii_utils.h"

void write_ascii_char(char c, char* file_name){
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Error! File with name: %s not found!\n", file_name);
        return;
    }

    //This only works for row amounts for a single ascii art smaller than 10!
    //short row_count = (short)fgetc(fptr) - 48;

    char buff[100];
    fgets(buff, sizeof(buff), fptr);
    short row_count = (short)atoi(buff);

    char c2;
    while ((c2 = fgetc(fptr)) != EOF) {
        printf("%c", c2);
    }
    fclose(fptr);
    printf("\n");
}
