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
DDArray *createCentroids(const unsigned int seed, const size_t k, DDArray *darr);
DDArray *populatedDDArray(const size_t n, const size_t m);

void printDDArray(DDArray *darr);
DDArray *destroyDDArray(DDArray *darr);
DDArray *testDDArray(const size_t n, const size_t m);

double **centroids(const size_t k, double **data, const size_t n, const size_t m);
#endif // _DEF_ALT_LIB
