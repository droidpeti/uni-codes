#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
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

Canvas canvas_create(int width, int height, color_e color){
	Canvas canvas;
	canvas.width = width;
	canvas.height = height;

	canvas.pixels = (color_e *)calloc(width*height, sizeof(color_e));
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

void canvas_delete(Canvas *canvas){
	free(canvas->pixels);
	canvas = NULL;
}

void canvas_print(Canvas *canvas){
	for(int i = 0; i < canvas->height; i++){
		for(int j = 0; j < canvas->width; j++){
			print_in_color(canvas->pixels[(i*canvas->width) + j]);
		}
		printf("\n");
	}
}

color_e color_converter(char *color_str){
	for(int i = 0; color_str[i] != '\0'; i++){
		color_str[i] = tolower(color_str[i]);
	}

	if(strcmp(color_str, "blue") == 0){
		return 1;
	}
	else if(strcmp(color_str, "red") == 0){
		return 2;
	}
	else if(strcmp(color_str, "magenta") == 0){
		return 3;
	}
	else if(strcmp(color_str, "green") == 0){
		return 4;
	}
	else if(strcmp(color_str, "cyan") == 0){
		return 5;
	}
	else if(strcmp(color_str, "yellow") == 0){
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

	for(int i = x1; i <= x2; i++){
		for(int j = y1; j <= y2; j++){
			canvas->pixels[(j * canvas->width) + i] = rect->color;
		}
	}
}

void canvas_load_from_file(char *file_name){
	FILE *fptr = fopen(file_name, "r");
	if(fptr == NULL){
		printf("Couldn't find file %s!\n", file_name);
		exit(1);
	}
	int width, height;
	color_e color;
	
	char buf[255];
	fgets(buf, sizeof(buf), fptr);
	buf[strcspn(buf, "\r\n")] = '\0';
	const char *delimiter = " ";
	char *token = strtok(buf, delimiter);
	int a = 0;
	while(token != NULL){
		if(a == 0){
			width = atoi(token);
		}
		else if(a == 1){
			height = atoi(token);
		}
		else if(a == 2){
			color = color_converter(token);
		}
		token = strtok(NULL, delimiter);
		a++;
	}

	Canvas canvas = canvas_create(width, height, color);

	while(fgets(buf, sizeof(buf), fptr) != NULL){
		buf[strcspn(buf, "\r\n")] = '\0';
		token = strtok(buf,delimiter);
		a = 0;
		Rectangle rect;
		while(token != NULL){
			if(a == 0){
				rect.x1 = atoi(token);
			}
			else if(a == 1){
				rect.y1 = atoi(token);
			}
			else if(a == 2){
				rect.x2 = atoi(token);
			}
			else if(a == 3){
				rect.y2 = atoi(token);
			}
			else if(a == 4){
				rect.color = color_converter(token);
			}
			token = strtok(NULL, delimiter);
			a++;
		}
		canvas_fill(&canvas, &rect);
	}
	fclose(fptr);
	
	canvas_print(&canvas);
	canvas_delete(&canvas);
}
