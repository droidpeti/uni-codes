#include <stdio.h>

int main(){
    {
        int a = 10;
        {
            int b = 20;
            {
                int c = 30;
                {
                    int d = 40;
                    printf("I can reach a, b, c and d here! %d %d %d %d\n", a,b,c,d);
                }
                printf("I can reach a, b and c here! %d %d %d\n", a,b,c);
            }
            printf("I can reach a and b here! %d %d\n", a,b);
        }
        printf("I can reach a here! %d\n", a);
    }
    // once a block/scope ends the variables declared inside it are no longer being stored in the stack/memory
    // these are great because we only use memory to store variables where we need to
    return 0;
}