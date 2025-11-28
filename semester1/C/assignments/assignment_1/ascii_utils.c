#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "ascii_utils.h"

void free_alphabet(Alphabet* alpha) {
    for (int i = 0; i < 26; i++) {
        for (int row = 0; row < alpha->height; row++) {
            free(alpha->letters[i].lines[row]);
        }
        free(alpha->letters[i].lines);
    }
}

Alphabet read_file(char* file_name){
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Error! File with name: %s not found!\n", file_name);
        exit(1);
    }
    Alphabet alphabet;

    char buff[128];
    if (fgets(buff, sizeof(buff), fptr) == NULL) {
         exit(1);
    }
    alphabet.height = (short)atoi(buff);

    for(int i = 0; i < 26; i++){
        alphabet.letters[i].lines = malloc(alphabet.height * sizeof(char*));
        
        if (alphabet.letters[i].lines == NULL) {
            perror("Memory allocation failed!");
            exit(1);
        }

        for(int row = 0; row < alphabet.height; row++) {
            if(fgets(buff, sizeof(buff), fptr) == NULL) {
                break;
            }
            buff[strcspn(buff, "\r\n")] = '\0';
            int length = strlen(buff);
            alphabet.letters[i].lines[row] = malloc(length + 1);

            if(alphabet.letters[i].lines[row] == NULL) {
                perror("Memory allocation failed!");
                exit(1);
            }
            strcpy(alphabet.letters[i].lines[row], buff);
        }
    }

    fclose(fptr);
    return alphabet;
}

void draw_str(char* word, int count, Alphabet* alphabet){
    for(int i = 0; i < alphabet->height; i++){
        for(int j = 0; j < count; j++){
            char c = tolower(word[j]);
            if (c >= 'a' && c <= 'z') {
                short char_idx = (short)(c - 'a');
                printf("%s", alphabet->letters[char_idx].lines[i]);
            }        
        }
        printf("\n");
    }
    
}
