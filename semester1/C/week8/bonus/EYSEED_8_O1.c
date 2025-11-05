#include <stdio.h>

int main(){
    for(int i = 0; i < 10; i++){
        int j = 0;
        while(j < 10){
            // I can reach both i and j here.
            printf("%d * %d = %d\n", i+1, j+1, (i+1)*(j+1));
            j++;
        }
    }
    return 0;
}
