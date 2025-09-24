#include<stdio.h>
#include<math.h>

int main(){
    int width;
    int height;
    printf("Enter width of multiplication table: ");
    scanf("%d", &width);
    printf("\nEnter height of multiplication table: ");
    scanf("%d", &height);
    printf("\n");
    if(width < 1){
        width = 10;
    }
    if(height < 1){
        height = 10;
    }
    for(int i = 1; i <= height; i++){
        for(int j = 1; j <= width; j++){
            printf("%*d\t", (int)ceil(log10(width*height))+1 ,i*j);
        }
        printf("\n");
    }
    return 0;
}

//Git Test 2
