#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct {
    char* team;
    double cur_points;
    double prev_points;
    int cur_rank;
    int prev_rank;
} Record;

int main(){
    char file_name[] = "fifa.txt";
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Error! File with name: %s not found!\n", file_name);
        return 1;
    }

    char buff[128];
    if (fgets(buff, sizeof(buff), fptr) == NULL) {
         exit(1);
    }

    rewind(fptr);
    int record_count = -1;

    while (fgets(buff, sizeof(buff), fptr) != NULL){
        record_count++;
    }

    Record *teams = (Record*) malloc(record_count * sizeof(Record));
    if (teams == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    rewind(fptr);
    fgets(buff, sizeof(buff), fptr);

    for(int i = 0; i < record_count; i++){
        fgets(buff, sizeof(buff), fptr);
        buff[strcspn(buff, "\r\n")] = 0;
        const char delimiter[] = ",";
        char *token = strtok(buff, delimiter);
        int j = 0;
        while(token != NULL){
            if(j == 0){
                teams[i].team = strdup(token);
            }
            else if(j == 1){
                teams[i].cur_points = atof(token);
            }
            else if(j == 2){
                teams[i].prev_points = atof(token);
            }
            token = strtok(NULL, delimiter);
            j++;
        }
    }
    fclose(fptr);


    int un_count = 0;

    for(int i = 0; i < record_count; i++){
        if(strstr(teams[i].team, "un")){
            un_count++;
        }
    }
    printf("Team names containing un: %d\n", un_count);

    double sum = 0;

    for(int i = 0; i < record_count; i++){
        sum += teams[i].cur_points;
    }

    double avg = sum / (double)record_count;

    printf("Avg: %.2lf\n", avg);

    for(int i = 0; i < record_count; i++){
        int cur_place = 1;
        int prev_place = 1;
        for(int j = 0; j < record_count; j++){
            if(teams[i].cur_points < teams[j].cur_points){
                cur_place++;
            }
            if(teams[i].prev_points < teams[j].prev_points){
                prev_place++;
            }
        }
        teams[i].cur_rank = cur_place;
        teams[i].prev_rank = prev_place;

        printf("%s: %d, %d\n", teams[i].team, cur_place, prev_place);
    }

    int best_imp_idx = -1;
    int max_imp_val = -1;
    
    int worst_drop_idx = -1;
    int max_drop_val = -1;

    for(int i = 1; i < record_count; i++){
        int diff = teams[i].cur_rank - teams[i].prev_rank;
        if(diff < 0){
            if(diff * -1 > max_drop_val){
                max_drop_val = diff;
                worst_drop_idx = i;
            }
        }
        else if(diff > 0){
            if(diff > max_imp_val){
                max_imp_val = diff;
                best_imp_idx = i;
            }
        }
    }

    printf("Most improved team is: %s with %d places\n", teams[best_imp_idx].team, max_imp_val);
    printf("Most decreased team is: %s with %d places\n", teams[worst_drop_idx].team, max_drop_val);

    int min_change_id = 0;
    double min_diff = teams[0].cur_points - teams[0].prev_points;
    if(min_diff < 0){
        min_diff *= -1;
    }

    for(int i = 1; i < record_count; i++){
        double diff = teams[i].cur_points - teams[i].prev_points;
        if(diff < 0){
            diff *= -1;
        }
        if(diff < min_diff){
            min_change_id = i;
            min_diff = diff;
        }
    }

    printf("Smallest point change: %s (%.2f)\n", teams[min_change_id].team, min_diff);

    for(int i = 0; i < record_count; i++){
        free(teams[i].team);
    }

    free(teams);

    return 0;
}
