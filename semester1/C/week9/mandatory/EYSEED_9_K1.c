#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int contains(int *haystack, int needle, int count) {
    for (int i = 0; i < count; i++) {
        if (haystack[i] == needle) {
            return 1;
        }
    }
    return 0;
}

void string_word_char(){
    char buff[100];
    printf("Enter a string: ");
    fgets(buff, sizeof(buff), stdin);
    buff[strcspn(buff, "\n")] = '\0';
    int i = 0;
    int word_count = 0;
    int in_word = 0;

    while(buff[i] != '\0'){
        if(buff[i] != ' '){
            in_word = 0;
        }
        else if(in_word == 0){
            in_word = 1;
            word_count++;
        }
        if(i == 0 && buff[i] != ' '){
            word_count = 1;
        }
        i++;
    }

    printf("%s has %d words and %d charachters\n", buff, word_count, i);
}

void compare_strings(){
    char str1[100];
    char str2[100];
    printf("Please input the first string: ");
    scanf("%99s", str1);
    printf("Please input the second string: ");
    scanf("%99s", str2);


    if(strcmp(str1, str2) == 0){
        printf("The two strings %s and %s match!\n", str1, str2);
        return;
    }
    printf("The two strings %s and %s don't match!\n", str1, str2);
}

void copy_string(){
    char str1[100];
    printf("Please input a string: ");
    scanf("%99s", str1);
    char str2[100];
    strcpy(str2,str1);
    printf("The copied value: %s\n", str2);
}

void char_pointer_array(){
    char str1[] = "Hello, ";
    char *str2 = "World!";
    char *ptr = malloc(strlen(str2) + 1);
    if(ptr != NULL){
        strcpy(ptr, str2);
    }
    else{
        printf("Memory allocation failed!\n");
        return;
    }

    str1[0] = 'B';
    //str2[0] = 'B'; You can't modify it like this
    ptr[0] = 'B';
    printf("%s%s\n",str1,ptr);
}

void read_file(char file_name[]){
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Error!\n");
        return;
    }

    char c;
    while ((c = fgetc(fptr)) != EOF) {
        printf("%c", toupper(c));
    }
    fclose(fptr);
    printf("\n");
}

void copy_capitalized_file(char source_file[], char destination_file[]){
    FILE *fptr = fopen(source_file, "r");
    if(fptr == NULL){
        printf("Error!\n");
        return;
    }

    FILE *write = fopen(destination_file, "w");
    if(write == NULL){
        printf("Error!\n");
        return;
    }

    char c;
    while ((c = fgetc(fptr)) != EOF) {
        fputc(toupper(c), write);
    }
    fclose(fptr);
}

int main(int argc, char **argv){
    if(argc < 2){
        printf("You need to enter a paramterer!\n");
        return 1;
    }
    int valid_params[] = {1,2,3,4,5,6};
    int param = atoi(argv[1]);
    if(!contains(valid_params, param, sizeof(valid_params)*sizeof(valid_params[0]))){
        printf("Invalid parameter!\n");
        return 1;
    }

    if(param == 1){
        string_word_char();
    }
    else if(param == 2){
        compare_strings();
    }
    else if(param == 3){
        copy_string();
    }
    else if(param == 4){
        char_pointer_array();
    }
    else if(param == 5){
        read_file("text.txt");
    }
    else if(param == 6){
        copy_capitalized_file("text.txt", "capitalized.txt");
    }

    return 0;
}
