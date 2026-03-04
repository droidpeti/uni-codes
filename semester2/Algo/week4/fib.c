#include <stdio.h>
#include <time.h>

// O(n)
int fib_iter(int n){
    if(n <= 1){
        return 0;
    }

    int x = 0;
    int y = 1;
    int z = 0;
    for(int i = 2; i <= n; i++){
        z = x + y;
        x = y;
        y = z;
    }

    return z;
}


 // O (phi ^ n)
int fib_rec(int n){
    if(n <= 1){
        return n;
    }
    return fib_rec(n-1) + fib_rec(n-2);
}

void multiply(int F[2][2], int M[2][2]) {
    int x = F[0][0] * M[0][0] + F[0][1] * M[1][0];
    int y = F[0][0] * M[0][1] + F[0][1] * M[1][1];
    int z = F[1][0] * M[0][0] + F[1][1] * M[1][0];
    int w = F[1][0] * M[0][1] + F[1][1] * M[1][1];

    F[0][0] = x;
    F[0][1] = y;
    F[1][0] = z;
    F[1][1] = w;
}

void power(int F[2][2], int n) {
    if (n == 0 || n == 1) return;

    int M[2][2] = {{1, 1}, {1, 0}};

    power(F, n / 2);
    multiply(F, F);

    if (n % 2 != 0) multiply(F, M);
}


// O (log n)
int fib(int n) {
    if (n == 0) return 0;

    int F[2][2] = {{1, 1}, {1, 0}};
    power(F, n - 1);

    return F[0][0];
}

int main(){
    int n = 10;
    float startTime;
    float endTime;
    float timeElapsed;

    startTime = (float)clock()/CLOCKS_PER_SEC;
    fib_iter(n);
    endTime = (float)clock()/CLOCKS_PER_SEC;
    timeElapsed = endTime - startTime;

    printf("For the iterative fibonacci function where n = %d, the run time was: %f\n", n, timeElapsed);

    startTime = (float)clock()/CLOCKS_PER_SEC;
    fib_rec(n);
    endTime = (float)clock()/CLOCKS_PER_SEC;
    timeElapsed = endTime - startTime;

    printf("For the recursive fibonacci function where n = %d, the run time was: %f\n", n, timeElapsed);

    return 0;
}
