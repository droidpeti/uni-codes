#include <stdio.h>
#include <stdlib.h>
#include <time.h>

struct Student
{
  double avg;
  int id;
  short age;
};
typedef struct Student Student;
//the order of the fields here effects memory size, due to the gaps
//the current version is the most optimal for memory

Student* student_init();
void student_print(Student* student);
Student* student_search(Student* students[], int count);

int main(){
    srand(time(NULL));
    const int STUD_CNT = 10;
    Student* students[STUD_CNT];

    for(int i = 0; i < STUD_CNT; i++){
        students[i] = student_init();
        if(!students[i]){
            return 1;
        }
        student_print(students[i]);
    }

    Student* max_avg_student = student_search(students, STUD_CNT);
    printf("The student with the highest average: ");
    student_print(max_avg_student);

    for(int i = 0; i < STUD_CNT; i++){
        free(students[i]);
    }

    return 0;
}

Student* student_init(){
    Student* student = malloc(sizeof(Student));
    if(!student){
        printf("Memory allocation failed!");
        return NULL;
    }
    student->id = (rand() % 100) + 1;
    student->avg = ((double)rand() / (double)RAND_MAX) * 100.0;
    student->age = (short)(rand() % 100) + 1;
    return student;
}

void student_print(Student* student){
    printf("Id: %d, average: %.2lf, age: %hi\n", student->id, student->avg, student->age);
}

Student* student_search(Student* students[], int count){
    if (count <= 0){
        return NULL;
    }
    Student* max_avg_student = students[0]; 
    for(int i = 0; i < count; i++){
        if(max_avg_student->avg < students[i]->avg){
            max_avg_student = students[i];
        }
    }
    return max_avg_student;
}
