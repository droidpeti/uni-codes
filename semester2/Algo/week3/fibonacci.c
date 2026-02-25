#include <stdio.h>

// Exact function calls: 2 * Fib(n+1) - 1
// Time Complexity: O(phi^n) where phi is the golden ratio (~1.618)
// Space Complexity: O(n) due to the call stack
int fib_rec(int n){
    if(n <= 1){
        return n;
    }
    return fib_rec(n-1) + fib_rec(n-2);
}

int main(){
    return 0;
}
