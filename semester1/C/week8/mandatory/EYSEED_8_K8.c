#include <stdio.h>
#include "my_utils.h"

int main(){
    for(int i = 0; i < 10; i++){
        static_increment();
    }
    // The static variable gets incremented successfully!
    return 0;
}
