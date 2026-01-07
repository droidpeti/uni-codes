#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "colors.h"

typedef struct{
	Color* pixels;
	int height;
	int width;
} Canvas;

typedef struct{
	int x1;
	int y1;
	int x2;
	int y2;
	Color color;
} Rectangle;

void delete_canvas(Canvas *canvas){
	free(canvas->pixels);
	canvas->pixels = NULL;
	canvas->height = 0;
	canvas->width = 0;
}

Canvas init_canvas(int height, int width, Color base_color){
	Canvas canvas;
	canvas.height = height;
	canvas.width = width;
	canvas.pixels = calloc(height*width, sizeof(Color));
	if(canvas.pixels == NULL){
		printf("Memory allocation failed!");
		exit(1);
	}

	for(int i = 0; i < height * width; i++){
		canvas.pixels[i] = base_color;
	}
	
	return canvas;
}

void canvas_print(Canvas canvas){
	for(int i = 0; i < canvas.height; i++){
		for(int j = 0; j < canvas.width; j++){
			set_bg_color(canvas.pixels[(i*canvas.width) + j]);
			printf(" ");
		}
		set_bg_color(0);
		printf("\n");
	}
}

Color color_converter(char* color_str){
    for(int i = 0; color_str[i] != '\0'; i++){
        color_str[i] = tolower(color_str[i]);
    }

    if(strcmp(color_str, "red") == 0){
    	return COLOR_RED;
    }
    else if(strcmp(color_str, "green") == 0){
    	return COLOR_GREEN;	
    } 
    else if(strcmp(color_str, "yellow") == 0){
    	return COLOR_YELLOW;	
    } 
    else if(strcmp(color_str, "blue") == 0){
    	return COLOR_BLUE;	
    }
    else if(strcmp(color_str, "magenta") == 0){
    	return COLOR_MAGENTA;
    } 
    else if(strcmp(color_str, "cyan") == 0){
    	return COLOR_CYAN;
    }
    else if(strcmp(color_str, "white") == 0){
    	return COLOR_WHITE;
    } 

    return COLOR_BLACK;
}


void canvas_fill(Canvas* canvas, Rectangle* rect){
	int x1 = rect->x1 < 0 ? 0 : rect->x1;
	int y1 = rect->y1 < 0 ? 0 : rect->y1;
	int x2 = rect->x2 > canvas->width ? canvas->width : rect->x2;
	int y2 = rect->y2 > canvas->height ? canvas->height : rect->y2;
	
	for(int y = y1; y < y2; y++){
	    for(int x = x1; x < x2; x++){
	        canvas->pixels[y * canvas->width + x] = rect->color;
	    }
	}
}

void canvas_load_from_file(char* file_name){
	FILE *fptr = fopen(file_name, "r");
	if(fptr == NULL){
		printf("Couldn't find file: %s\n", file_name);
		return;
	}
	char buf[256];
	
	fgets(buf, sizeof(buf), fptr);
	buf[strcspn(buf, "\r\n")] = '\0';
	int width;
	int height;
	Color color;

	const char delimiter[] = " ";
	char *token = strtok(buf, delimiter);
	int k = 0;
	while(token != NULL){
		if(k == 0){
			width = atoi(token);
		}
		else if(k == 1){
			height = atoi(token);
		}
		else if(k == 2){
			color = color_converter(token);
		}
		token = strtok(NULL, delimiter);
		k++;
	}

	Canvas canvas = init_canvas(height, width, color);

	int rect_count = 0;
	
	while(fgets(buf, sizeof(buf), fptr) != NULL){
		rect_count++;
	}

	Rectangle* rects = malloc(rect_count*sizeof(Rectangle));
	if(rects == NULL){
		printf("Memory allocation failed!");
		fclose(fptr);
		delete_canvas(&canvas);
		return;
	}
	rewind(fptr);
	fgets(buf, sizeof(buf), fptr);

	for(int i = 0; i < rect_count; i++){
		fgets(buf, sizeof(buf), fptr);
		buf[strcspn(buf, "\r\n")] = '\0';
		const char delimiter[] = " ";
		char *token = strtok(buf, delimiter);
		int j = 0;
		while(token != NULL){
			if(j == 0){
				rects[i].x1 = atoi(token);
			}
			else if(j == 1){
				rects[i].y1 = atoi(token);
			}
			else if(j == 2){
				rects[i].x2 = atoi(token);
			}
			else if(j == 3){
				rects[i].y2 = atoi(token);
			}
			else if(j == 4){
				rects[i].color = color_converter(token);
			}
			token = strtok(NULL, delimiter);
			j++;
		}
		canvas_fill(&canvas, &rects[i]);
	}
	free(rects);
	fclose(fptr);
	canvas_print(canvas);
	delete_canvas(&canvas);
}

int main(int argc, char** argv){
	if(argc == 2){
		char* file_name = argv[1];
		canvas_load_from_file(file_name);
		return 0;
	}
	else if(argc < 4){
		printf("Not enough parameters!\n");
		return 1;
	}
	Canvas canvas;
	{
		int width = atoi(argv[1]);
		int height = atoi(argv[2]);
		Color color = color_converter(argv[3]);
		canvas = init_canvas(height, width, color);
	}
	
	canvas_print(canvas);
	delete_canvas(&canvas);
	
	return 0;
}
