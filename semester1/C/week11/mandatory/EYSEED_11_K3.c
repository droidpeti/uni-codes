#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef enum {
    BSC,
    MSC,
    PHD
} Type;

typedef struct {
    double impact_factor;
    int erdos_number;
} PhdData;

typedef union {
    int courses_count;
    double credit_score;
    PhdData phd_info;
} ExtraData;

struct AdvStudent
{
  double avg;
  ExtraData data;
  int id;
  Type type;
  short age;
};
typedef struct AdvStudent AdvStudent;

AdvStudent* adv_student_init();
void adv_student_print(AdvStudent* student);
AdvStudent* adv_student_search(AdvStudent* students[], int count);

int main(){
    srand(time(NULL));
    const int STUD_CNT = 10;
    AdvStudent* students[STUD_CNT];

    for(int i = 0; i < STUD_CNT; i++){
        students[i] = adv_student_init();
        if(!students[i]){
            return 1;
        }
        adv_student_print(students[i]);
    }

    AdvStudent* max_avg_student = adv_student_search(students, STUD_CNT);
    printf("The student with the highest average: ");
    adv_student_print(max_avg_student);

    printf("Size of AdvStudent: %zu bytes\n", sizeof(AdvStudent));

    printf("Size without Union: %zu bytes + padding\n", sizeof(double) + sizeof(int) + sizeof(short) + sizeof(Type) + sizeof(int) + sizeof(double) + sizeof(PhdData));

    for(int i = 0; i < STUD_CNT; i++){
        free(students[i]);
    }

    return 0;
}

AdvStudent* adv_student_init(){
    AdvStudent* student = malloc(sizeof(AdvStudent));
    if(!student){
        printf("Memory allocation failed!");
        return NULL;
    }
    
    student->id = (rand() % 100) + 1;
    student->avg = ((double)rand() / (double)RAND_MAX) * 100.0;
    student->age = (short)(rand() % 100) + 1;
    student->type = (Type)(rand() % 3);

    switch (student->type) {
        case BSC:
            student->data.courses_count = (rand() % 10) + 20;
            break;
        case MSC:
            student->data.credit_score = ((double)rand() / (double)RAND_MAX) * 5.0 + 1.0;
            break;
        case PHD:
            student->data.phd_info.impact_factor = ((double)rand() / (double)RAND_MAX) * 10.0;
            student->data.phd_info.erdos_number = (rand() % 10) + 1;
            break;
    }

    return student;
}

void adv_student_print(AdvStudent* student){
    printf("Id: %d, average: %.2lf, age: %hi, ", student->id, student->avg, student->age);
    
    switch (student->type) {
        case BSC:
            printf("BSc, Courses: %d", student->data.courses_count);
            break;
        case MSC:
            printf("MSc, Credit score: %.2lf", student->data.credit_score);
            break;
        case PHD:
            printf("PhD, Impact: %.2lf, Erdos: %d", student->data.phd_info.impact_factor, student->data.phd_info.erdos_number);
            break;
    }
    printf("\n");
}

AdvStudent* adv_student_search(AdvStudent* students[], int count){
    if (count <= 0){
        return NULL;
    }

    AdvStudent* max_avg_student = students[0]; 
    for(int i = 1; i < count; i++){
        if(max_avg_student->avg < students[i]->avg){
            max_avg_student = students[i];
        }
    }
    return max_avg_student;
}
