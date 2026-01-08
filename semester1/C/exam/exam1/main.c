#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "utils.c"

int main(int argc, char **argv){
	if(argc == 2){
		char *file_name = argv[1];
		canvas_load_from_file(file_name);
		return 0;
	}
	else if(argc < 4){
		printf("Not enough parameters!\n");
		return 0;
	}

	int width = atoi(argv[1]);
	int height = atoi(argv[2]);
	char *color = argv[3];

	Canvas canvas = canvas_create(width, height, color_converter(color));
	canvas_print(&canvas);
	canvas_delete(&canvas);
	
	return 0;
}
