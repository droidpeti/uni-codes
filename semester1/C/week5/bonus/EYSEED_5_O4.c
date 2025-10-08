#include <stdio.h>

int main(){
    char string[] = "árvíztűrőtükörfúrógép";
    printf("Size of %s is %zu bytes\n", string, sizeof(string));
    return 0;
}
