#include <stdio.h>

// O(n^2)
double poly_inefficient(double* A, double x, int n){
    double s = 0;
    for(int i = 0; i < n; i++){
        double h = 1.0; 
        for(int j = 0; j < i; j++){
            h *= x;
        }
        s += A[i] * h;
    }
    return s;
}

double quick_pow(double base, int exp) {
    double res = 1.0;
    while (exp > 0) {
        if (exp % 2 == 1) res *= base;
        base *= base;
        exp /= 2;
    }
    return res;
}

// O(n log n) 
double poly_fast_pow(double* A, double x, int n) {
    double s = 0;
    for (int i = 0; i < n; i++) {
        s += A[i] * quick_pow(x, i);
    }
    return s;
}

// Horner's Method: O(n)
double poly_horner(double* A, double x, int n) {
    double s = 0;
    for (int i = n - 1; i >= 0; i--) {
        s = s * x + A[i];
    }
    return s;
}

int main() {
    double numbers[] = {5.0, 2.0, 3.0}; // 5 + 2x + 3x^2
    int n = sizeof(numbers)/sizeof(numbers[0]);
    double x = 2.0;

    printf("Polynomial: 3x^2 + 2x + 5, where x = %.2f\n", x);
    printf("----------------------------------------\n");

    printf("Inefficient (O(n^2)):   %10.2f\n", poly_inefficient(numbers, x, n));
    printf("Fast Pow (O(n*log n)):  %10.2f\n", poly_fast_pow(numbers, x, n));
    printf("Horner (O(n)):          %10.2f\n", poly_horner(numbers, x, n));

    return 0;
}
