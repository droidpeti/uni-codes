#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include "colors.h"

typedef struct{
	int height;
	int width;
	Color *pixels;
} Canvas;

typedef struct{
	int x1, x2, y1, y2;
	Color color;
} Rectangle;

Canvas create_canvas(int width, int height, Color color){
	Canvas canvas;
	canvas.width = width;
	canvas.height = height;
	canvas.pixels = (Color *)calloc(width*height, sizeof(Color));
	if(canvas.pixels == NULL){
		printf("Memory allocation failed!\n");
		exit(1);
	}

	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			canvas.pixels[(i*width) + j] = color;
		}
	}

	return canvas;
}

void delete_canvas(Canvas *canvas){
	free(canvas->pixels);
	canvas = NULL;
}

void print_canvas(Canvas *canvas){
	for(int i = 0; i < canvas->height; i++){
		for(int j = 0; j < canvas->width;j++){
			set_bg_color(canvas->pixels[(i*canvas->width) + j]);
			printf(" ");
		}
		set_bg_color(0);
		printf("\n");
	}
}

Color color_converter(char *color_str){
	for(int i = 0; color_str[i] != '\0'; i++){
		color_str[i] = tolower(color_str[i]);
	}

	if(strcmp(color_str, "red") == 0){
		return 1;
	}
	else if(strcmp(color_str, "green") == 0){
		return 2;
	}
	else if(strcmp(color_str, "yellow") == 0){
		return 3;
	}
	else if(strcmp(color_str, "blue") == 0){
		return 4;
	}
	else if(strcmp(color_str, "magenta") == 0){
		return 5;
	}
	else if(strcmp(color_str, "cyan") == 0){
		return 6;
	}
	else if(strcmp(color_str, "white") == 0){
		return 7;
	}
	return 0;
}

void canvas_fill(Canvas *canvas, Rectangle *rect){
	int x2 = rect->x2 < 0 ? 0 : rect->x2;
	int y2 = rect->y2 < 0 ? 0 : rect->y2;
	int x1 = rect->x1 > canvas->width ? canvas->width : rect->x1;
	int y1 = rect->y1 > canvas->height ? canvas->height : rect->y1;

	for(int i = x1; i < x2; i++){
		for(int j = y1; j < y2; j++){
			canvas->pixels[(i * canvas->width) + j] = rect->color;
		}
	}
}

void read_from_file(char *file_name){
	FILE *fptr = fopen(file_name, "r");
	if(fptr == NULL){
		printf("Couldn't find file!\n");
		exit(1);
	}
}

int main(int argc, char **argv){
	if(argc == 2){
		char *file_name = argv[1];
		read_from_file(file_name);
		return 1;
	}
	else if(argc < 4){
		printf("Not enough parameters!\n");
		return 0;
	}

	int width = atoi(argv[1]);
	int height = atoi(argv[2]);
	char *color = argv[3];

	Canvas canvas = create_canvas(width, height, color_converter(color));

	print_canvas(&canvas);

	delete_canvas(&canvas);
	
	return 0;
}
