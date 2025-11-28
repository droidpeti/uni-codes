#include <stdio.h>
#include "ascii_utils.h"

int main(int argc, char** argv){
    if(argc < 2){
        printf("No parameters provided, please provide the file's name!\n");
        return 1;
    }
    char* file_name = argv[1];    
    write_ascii_char('a', file_name);
    return 0;
}
