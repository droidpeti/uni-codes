#include <stdio.h>
#include <ctype.h>
#include <string.h>

int contains(char haystack[], char needle, int count){
    for(int i = 0; i < count; i++){
        if(haystack[i] == needle){
            return 1;
        }
    }
    return 0;
}

int main(){
    char string[255];
    char vowels[] = {'a', 'e', 'i', 'o', 'u'};
    char consonants[] = {'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'x', 'y', 'z'};
    printf("Please enter a word: ");
    scanf("%255s", string);
    size_t len = strlen(string); 

    int vowel_count = 0;
    int consonant_count = 0;

    for(int i = 0; i < (int)len; i++){
        char lower_c = tolower((unsigned char)string[i]); 

        if(contains(vowels, lower_c, (int)sizeof(vowels))){
            vowel_count++;
        }
        if(contains(consonants, lower_c, (int)sizeof(consonants))){
            consonant_count++;
        }
    }

    printf("%s contains %d vowel(s) and %d consonant(s)\n", string, vowel_count, consonant_count);

    return 0;
}
