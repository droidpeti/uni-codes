#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

typedef struct {
    char* name;
    char* team;
    int points;
} Driver;

typedef struct {
    char* name;
    int driver_count;
    int point_sum;
    char* max_driver;
    int max_point;
} Team;

int compare(const void* a, const void* b){
    Driver* d1 = *(Driver**)a;
    Driver* d2 = *(Driver**)b;
    return(strcmp(d1->name, d2->name));
}

int main(){
    char file_name[] = "f1_drivers.txt";
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Couldn't find file!\n");
        return 1;
    }
    int count = 0;
    char buff[256];
    while(fgets(buff, sizeof(buff), fptr) != NULL){
        count++;
    }
    Driver *drivers = (Driver*)calloc(count, sizeof(Driver)); 
    if(drivers == NULL){
        printf("Memory allocation failed\n");
        return 1;
    }

    rewind(fptr);

    for(int i = 0; i < count; i++){
        fgets(buff, sizeof(buff), fptr);
        buff[strcspn(buff, "\r\n")] = '\0';
        const char delimiter[] = ";";
        char* token = strtok(buff, delimiter);
        int j = 0;
        while(token != NULL){
            if(j == 0){
                drivers[i].name = strdup(token);
            }
            else if(j == 1){
                drivers[i].team = strdup(token);
            }
            else if(j == 2){
                drivers[i].points = atoi(token);
            }
            token = strtok(NULL, delimiter);
            j++;
        }
    }
    fclose(fptr);

    int team_count = 0;
    Team* teams = NULL;

    for(int i = 0; i < count; i++){
        int contains = 0;
        for(int j = 0; j < team_count; j++){
            if(strcmp(drivers[i].team, teams[j].name) == 0){
                contains = 1;
            }
        }
        if(!contains){
            Team* temp = realloc(teams, sizeof(Team) * (++team_count));
            if(temp == NULL){
                printf("Memory allocation failed\n");
                for(int i = 0; i < count; i++){
                    free(drivers[i].name);
                    free(drivers[i].team);
                }
                free(drivers);
                return 1;
            }
            teams = temp;
            teams[team_count-1].name = drivers[i].team;
            teams[team_count-1].driver_count = 0;
            teams[team_count-1].point_sum = 0;
            teams[team_count-1].max_point = INT_MIN;
        }
    }

    for(int i = 0; i < team_count; i++){
        for(int j = 0; j < count; j++){
            if(strcmp(drivers[j].team, teams[i].name) == 0){
                teams[i].driver_count++;
                teams[i].point_sum += drivers[j].points;
                if(drivers[j].points > teams[i].max_point){
                    teams[i].max_point = drivers[j].points;
                    teams[i].max_driver = drivers[j].name;
                }
            }
        }
        printf("%s's driver count is: %d\n", teams[i].name, teams[i].driver_count);
        printf("%s's points are: %d\n", teams[i].name, teams[i].point_sum);
        printf("%s's best performing driver is: %s, with %d points\n", teams[i].name, teams[i].max_driver, teams[i].max_point);
    }

    printf("Please enter a number: ");
    int num;
    scanf("%d", &num);

    for(int i = 0; i < count; i++){
        if(drivers[i].points > num){
            printf("%s has more points than %d\n", drivers[i].name, num);
        }
    }
    
    if(team_count > 0){
        Team last_team = teams[team_count-1];
        int* last_team_count = &last_team.driver_count;
        Driver** sorted_drivers = malloc(sizeof(Driver*) * *last_team_count);

        int k = 0;
        for(int i = 0; i < count; i++){
            if(strcmp(drivers[i].team, last_team.name) == 0){
                sorted_drivers[k++] = &drivers[i];
            }
        }

        qsort(sorted_drivers, *last_team_count, sizeof(Driver*), compare);

        printf("%s's drivers in alphabetical order:\n", last_team.name);
        for(int i = 0; i < *last_team_count; i++){
            printf("%s\n", sorted_drivers[i]->name);
        }

        free(sorted_drivers);
    }

    free(teams);
    for(int i = 0; i < count; i++){
        free(drivers[i].name);
        free(drivers[i].team);
    }
    free(drivers);

    return 0;
}
