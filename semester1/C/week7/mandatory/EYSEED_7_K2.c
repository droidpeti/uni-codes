#include <stdio.h>

void fill_matrix(int *matrix, int count_x, int count_y){
    for(int i = 0; i < count_x; i++){
        for(int j = 0; j < count_y; j++){
            matrix[count_x*i+j] = (i+1)*(j+1);
        }
    }
}

int main(){
    const int count_x = 10;
    const int count_y = 10;
    int matrix[count_x][count_y];
    fill_matrix(*matrix, count_x, count_y);

    for(int i = 0; i < count_x; i++){
        for(int j = 0; j < count_y; j++){
            printf("%d x %d = %d\n", (i+1), (j+1), matrix[i][j]);
        }
    }

    return 0;
}
