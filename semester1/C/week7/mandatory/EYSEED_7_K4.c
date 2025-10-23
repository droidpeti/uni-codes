#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char **argv){

    if(argc < 3){
        printf("Invalid input parameters!\n");
        return 1;
    }
    char *endptr;
    double base;

    base = strtod(argv[1], &endptr);
    if (*endptr != '\0') {
        printf("Error: '%s' is not a valid double.\n", argv[1]);
        return 1;
    }

    long n;

    n = strtol(argv[2], &endptr, 10);
    if (*endptr != '\0') {
        printf("Error: '%s' is not a valid integer.\n", argv[2]);
        return 1;
    }

    for(long i = 0; i < n; i++){
        printf("%lf ^ %ld = %lf\n", base, i+1, pow(base,i+1));
    }

    return 0;
}
