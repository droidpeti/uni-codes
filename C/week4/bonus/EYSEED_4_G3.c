#include <stdio.h>

int fact(int num){
    if(num > 0){
        return num*fact(num-1);
    }
    return 1;
}

int main(){
    int final_row;
    printf("Please input how many rows of Pascal's Triangle you would like to see: ");
    scanf("%d", &final_row);
    for(int i = 0; i < final_row; i++){
        for(int j = 0; j <= i; j++){
            //i! / (j!(i-j)!)
            printf("%d ", fact(i)/(fact(j)*(fact(i-j))));
        }
        printf("\n");
    }

    return 0;
}