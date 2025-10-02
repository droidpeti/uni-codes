#include <stdio.h>

int main(){
    int month;
    printf("Please input a number which corresponds to a month (1-12): ");
    do{
        scanf("%d", &month);
        if(month < 1 || month > 12){
            printf("Incorrect input!\nPlease enter a number between 1 and 12: ");
        }
    }while(month < 1 || month > 12);

    printf("This month is in ");
    if(month == 12 || month <= 2){
        printf("winter");
    }
    else if(month <= 5){
        printf("spring");
    }
    else if(month <= 8){
        printf("summer");
    }
    else{
        printf("autumn");
    }
    printf("\n");
    return 0;
}