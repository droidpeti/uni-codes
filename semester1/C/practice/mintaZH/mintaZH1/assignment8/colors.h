#ifndef COLORS_H
#define COLORS_H

#include <stdio.h>

typedef enum {
    COLOR_BLACK = 0,
    COLOR_RED,
    COLOR_GREEN,
    COLOR_YELLOW,
    COLOR_BLUE,
    COLOR_MAGENTA,
    COLOR_CYAN,
    COLOR_WHITE
} Color;

static inline void set_bg_color(Color c)
{
    switch (c) {
        case COLOR_BLACK:   printf("\033[40m"); break;
        case COLOR_RED:     printf("\033[41m"); break;
        case COLOR_GREEN:   printf("\033[42m"); break;
        case COLOR_YELLOW:  printf("\033[43m"); break;
        case COLOR_BLUE:    printf("\033[44m"); break;
        case COLOR_MAGENTA: printf("\033[45m"); break;
        case COLOR_CYAN:    printf("\033[46m"); break;
        case COLOR_WHITE:   printf("\033[47m"); break;
    }
}

#endif
