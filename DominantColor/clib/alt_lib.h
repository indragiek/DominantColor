#ifndef _DEF_ALT_LIB
#define _DEF_ALT_LIB

#include "defs.h"

typedef struct {
    double **data;
    size_t n, m;
    unsigned int isAllocd:1; 
} DDArray;

int *kMeans(double **data, int n, int m,
                        int k, double t, double **centroids);

DDArray *newDDArray(const size_t n, const size_t m);
DDArray *createCentroids(const size_t k, DDArray *darr);
DDArray *populateCluster(double **data, const size_t n, const size_t m);

void printDDArray(DDArray *darr);
DDArray *destroyDDArray(DDArray *darr);
#endif // _DEF_ALT_LIB
