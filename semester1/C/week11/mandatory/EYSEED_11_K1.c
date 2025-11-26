#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void init(int* id, double* avg, short* age, int count);

int main(){
    srand(time(NULL));
    const int STUD_CNT = 10;
    int ids[STUD_CNT];
    double avgs[STUD_CNT];
    short ages[STUD_CNT];

    //This isn't well maintainable, a struct array would be better for maintanability

    init(ids, avgs, ages, STUD_CNT);

    for(int i = 0; i < STUD_CNT; i++){
        printf("%d: %d %.2lf %hi\n", i+1, ids[i], avgs[i], ages[i]);
    }

    return 0;
}

void init(int* id, double* avg, short* age, int count){
    for(int i = 0; i < count; i++){
        id[i] = (rand() % 100) + 1;
        avg[i] = ((double)rand() / (double)RAND_MAX) * 100.0;
        age[i] = (short)(rand() % 100) + 1;
    }
}
