#include <stdio.h>

void func(){
    printf("Hello world!\n");
}

void (*return_func_pointer())(){
    void (*ptr)();
    ptr = &func;
    return ptr;
}

int main(){
    void (*ptr)();
    ptr = return_func_pointer();
    ptr();
    return 0;
}
