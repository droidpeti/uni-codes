#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int **numbers;
    size_t count;
    size_t capacity;
} Database;

Database* db_create(size_t initial_capacity);
void db_insert(Database *db, int num);

int main(){
    db_create(2);

    return 0;
}

Database* db_create(size_t initial_capacity){
    Database *db = (Database*)malloc(sizeof(Database));

    if(!db){
        printf("Failed to allocate memory!");
        exit(1);
    }

    db->capacity = initial_capacity;
    db->count = 0;

    db->numbers = (int**)calloc(initial_capacity, sizeof(int*));

    if(!db->numbers){
        printf("Failed to allocate memory!");
        free(db);
        exit(1);
    }

    return db;
}

void db_insert(Database* db, int num){
    if(db->count >= db->capacity){
        size_t new_capacity = db->capacity * 2;

        int **new_numbers = (int**)realloc(db->capacity, new_capacity * sizeof(int*));
        if(!new_numbers){
            printf("Memory allocation failed!");
            exit(1);
        }
        db->capacity = new_capacity;
        db->numbers = new_numbers;
    }

    int *new_num = (int*)malloc(sizeof(int));
    if(!new_num){
        printf("Memory allocation failed!");
        exit(1);
    }

    db->numbers[db->count] = new_num;
    db->count++;
    printf("Succesfully added new number!");
}
