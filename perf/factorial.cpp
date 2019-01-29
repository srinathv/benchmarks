#include <stdio.h>

unsigned long long fact(unsigned long long n) {
    if (n <= 1) return 1;
    else return n * fact(n - 1);
}

int main(int argc, char* argv[]) {
    unsigned long long x, i;
    for (x = 0; x < 10; x++) {
        for (i = 1; i <= 20; i++) {
            printf("%lld\n", fact(i));
        }
    }
    return 0;
}
