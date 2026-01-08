#ifndef UTILS_HEADER__
#define UTILS_HEADER__

#include "colors.h"

typedef struct{
	int width;
	int height;
	color_e *pixels;
} Canvas;

typedef struct{
	int x1, x2, y1, y2;
	color_e color;
} Rectangle;

Canvas canvas_create(int width, int height, color_e color);
void canvas_delete(Canvas *canvas);
void canvas_print(Canvas *canvas);
color_e color_converter(char *color_str);
void canvas_fill(Canvas *canvas, Rectangle *rect);
void canvas_load_from_file(char *file_name);

#endif
