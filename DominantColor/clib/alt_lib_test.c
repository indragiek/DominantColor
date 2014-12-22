#include <time.h>
#include <stdio.h>
#include <stdlib.h>

#include "alt_lib.h"

int main(int argc, char *argv[]) {
    int *clusterLabels;
    unsigned long int ms;
    size_t k = 16, n = 100;
    DDArray *darr, *centroids;
    clock_t diff, start = clock();

    if (argc >= 2 && sscanf(argv[1], "%zd", &n) != 1) {
        n = 100;
    }

    printf("\033[92mn: %zd \033[94mk: %zd\033[00m\n", n, k);

    darr = populatedDDArray(n, 3);
    centroids = createCentroids(9000, k, darr);
    clusterLabels = kMeans(darr->data, darr->n, darr->m, centroids->n, 0.01, centroids->data);

#ifdef DEBUG
    size_t i;
    for (i = 0; i < k; ++i) {
        printf("%d\n", clusterLabels[i]); 
    }
#endif

    free(clusterLabels);

#ifdef DEBUG
    printDDArray(centroids);
    printDDArray(darr);
#endif // DEBUG

    destroyDDArray(darr);
    destroyDDArray(centroids);

    diff = clock() - start;
    ms = diff * 1000 / CLOCKS_PER_SEC;
    printf("Timing: %ld ms diff: %ld\n", ms, diff);

    return 0;
}
