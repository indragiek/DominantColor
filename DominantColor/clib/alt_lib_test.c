#include <stdio.h>
#include <stdlib.h>

#include "alt_lib.h"
#include "azzert.h"

int main() {
    double d[][4] = {
        {0.1, 0, 4, 96},
        {1000.1, 24, 24, 6},
        {0.1, 24, 4, 746},
        {0.1, 24, 4, 46},
        {55, 24, 4, 66.9},
        {4.1, 24, 4, 26},
        {60.1, 24, 4, 9},
    #ifdef XP
        {0.1, 24, 18, 8},
        {0.1, 24, 4, 6},
        {0.1, 0.091, 4, 6},
        {9.99, 94, 4, 6},
        {10.1, 24, 4, 6},
        {0.1, 24, 49., 6},
        {0.7, 24, 4, 698},
        {0.9, 24, 0.04, 67},
        {0.1, 24, 4, 0.06},
    #endif
    };

    size_t len = ARRAY_SIZE(d);
    size_t m = sizeof(d[0])/sizeof(d[0][0]);
    DDArray darr = {
        .data = (double **)d,
        .n = len,
        .m = m,
    };

    destroyDDArray(&darr);

    return 0;
}
