#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
    char* name;
    char* mountain;
    double height;
} Record;

int contains(char* needle, char** haystack, int count){
    for(int i = 0; i < count; i++){
        if(strcmp(needle, haystack[i]) == 0){
            return 1;
        }
    }
    return 0;
}

int compareRecords(const void *a, const void *b) {
    Record *recA = *(Record **)a;
    Record *recB = *(Record **)b;
    
    if (recA->height < recB->height) return -1;
    if (recA->height > recB->height) return 1;
    return 0;
}

int main(){
    char file[] = "hegyekMo.txt";

    FILE *fptr = fopen(file, "r");
    if(fptr == NULL){
        printf("Couldn't find %s\n", file);
        return 1;
    }

    char buff[128];
    int count = -1;

    while(fgets(buff, sizeof(buff), fptr) != NULL){
        count++;
    }

    Record *mounts = (Record*) calloc(count, sizeof(Record));

    if(mounts == NULL){
        printf("Memory allocation failed!\n");
        fclose(fptr);
        return 1;
    }

    rewind(fptr);
    fgets(buff, sizeof(buff), fptr);

    for(int i = 0; i < count; i++){
        fgets(buff, sizeof(buff), fptr);
        buff[strcspn(buff, "\r\n")] = '\0';
        const char delimiter[] = ";";
        char *token = strtok(buff, delimiter);
        int j = 0;
        while(token != NULL){
            if(j == 0){
                mounts[i].name = strdup(token);
            }
            else if(j == 1){
                mounts[i].mountain = strdup(token);
            }
            else if(j == 2){
                mounts[i].height = atof(token);
            }
            token = strtok(NULL, delimiter);
            j++;
        }
    }
    fclose(fptr);

    int mountain_count = 1;
    char** mountains = malloc(mountain_count * sizeof(char*));
    mountains[0] = mounts[0].mountain;

    for(int i = 1; i < count; i++){
        if(!contains(mounts[i].mountain, mountains, mountain_count)){
            char** temp = realloc(mountains, (++mountain_count)*sizeof(char*));
            if (temp != NULL) {
                mountains = temp;
            }
            else {
                free(mountains); 
                return 1;
            }
            mountains[mountain_count-1] = mounts[i].mountain;
        }
    }

    int *mount_by_mountain = (int*) calloc(mountain_count, sizeof(int));
    double *sum_by_mountain = (double*) calloc(mountain_count, sizeof(double));
    double *max_by_mountain = (double*) calloc(mountain_count, sizeof(double));

    if(mount_by_mountain == NULL || sum_by_mountain == NULL || max_by_mountain == NULL){
        printf("Memory allocation failed!\n");
        return 1;
    }

    for(int i = 0; i < mountain_count; i++){
        for(int j = 0; j < count; j++){
            if(strcmp(mountains[i], mounts[j].mountain) == 0){
                mount_by_mountain[i]++;
                sum_by_mountain[i] += mounts[j].height;
                if(mounts[j].height > max_by_mountain[i]){
                    max_by_mountain[i] = mounts[j].height;
                }
            }
        }
        printf("%s's mount count: %d\n", mountains[i], mount_by_mountain[i]);
    }
    
    int sum = 0;
    for(int i = 0; i < count; i++){
        sum += mounts[i].height;
    }

    printf("The average height of the peaks is: %lfm\n", (double)sum/(double)count);
    for(int i = 0; i < mountain_count; i++){
        printf("%s's average peak height is: %lfm\n", mountains[i], sum_by_mountain[i]/(double)mount_by_mountain[i]);
    }

    for(int i = 0; i < mountain_count; i++){
        printf("%s's maximum peak height is: %lfm\n", mountains[i], max_by_mountain[i]);
    }

    double num;
    printf("Please input a number: ");
    scanf("%lf", &num);

    for(int i = 0; i < count; i++){
        if(mounts[i].height > num){
            printf("%s is taller than %lfm\n", mounts[i].name, num);
        }
    }

    printf("%s's peaks in ascending order\n", mountains[0]);

    Record **first_mountain_peaks = malloc(mount_by_mountain[0] * sizeof(Record*));
    
    int k = 0;
    for (int i = 0; i < count; i++) {
        if (strcmp(mounts[i].mountain, mountains[0]) == 0) {
            first_mountain_peaks[k++] = &mounts[i];
        }
    }
    
    qsort(first_mountain_peaks, mount_by_mountain[0], sizeof(Record*), compareRecords);

    for (int i = 0; i < mount_by_mountain[0]; i++) {
        printf("%s: %.2lf m\n", first_mountain_peaks[i]->name, first_mountain_peaks[i]->height);
    }

    free(first_mountain_peaks);

    free(mount_by_mountain);
    free(sum_by_mountain);
    free(max_by_mountain);
    free(mountains);

    for(int i = 0; i < count; i++){
        free(mounts[i].name);
        free(mounts[i].mountain);
    }
    
    free(mounts);


    return 0;
}
