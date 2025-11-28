#include <stdio.h>
#include <string.h>
#include "ascii_utils.h"

int main(int argc, char** argv){
    if(argc < 2){
        printf("No parameters provided, please provide the file's name!\n");
        return 1;
    }
    char* file_name = argv[1];
    Alphabet alphabet = read_file(file_name);

    printf("Please enter words to display in ascii art, enter EOF (Ctrl+D Unix or Ctrl+Z Windows) to stop!\n");

    char input_buff[256];
    while(fgets(input_buff, sizeof(input_buff), stdin) != NULL) {
        input_buff[strcspn(input_buff, "\r\n")] = '\0';
        draw_str(input_buff, strlen(input_buff), &alphabet);
    }

    free_alphabet(&alphabet);

    return 0;
}
