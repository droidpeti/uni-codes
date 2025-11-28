#ifndef ASCII_UTILS_H
#define ASCII_UTILS_H

typedef struct {
    char** lines;
    short width;
} Letter;

typedef struct {
    short height;
    Letter letters[26];
} Alphabet;

void draw_str(char* word, int count, Alphabet* alphabet);
Alphabet read_file(char* file_name);
void free_alphabet(Alphabet* alpha);

#endif
