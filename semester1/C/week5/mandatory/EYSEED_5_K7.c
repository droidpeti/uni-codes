#include <stdio.h>

int main(){
    int array_length = 256;
    char string[array_length];
    char string2[array_length];

    printf("Please input the first string: ");
    scanf("%255s", string);
    printf("Please input the second string: ");
    scanf("%255s", string2);

    char *first = string;

    for(int i = 0; i < array_length; i++){
        if(string[i] == '\0'){
            break;
        }
        if(string2[i] == '\0'){
            first = string2;
            break;
        }
        if(string2[i] < string[i]){
            first = string2;
            break;
        }
        if(string[i] < string2[i]){
            break;
        }
    }

    printf("%s is the first alphanumerically\n", first);

    return 0;
}
