#include <stdio.h>

void towerOfHanoi(int n, char fromRod, char toRod, char auxRod) {
    if (n == 0) {
        return;
    }
    towerOfHanoi(n - 1, fromRod, auxRod, toRod);
    printf("Disk %d moved from %c to %c\n", n, fromRod, toRod);
    towerOfHanoi(n - 1, auxRod, toRod, fromRod);
}

int main() {
    int n = 7;

    // A, B and C are names of rods
    towerOfHanoi(n, 'A', 'C', 'B');
    return 0;
}
