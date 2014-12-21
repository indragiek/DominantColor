#ifndef AZZERT_H
#define  AZZERT_H

#include <stdarg.h>
#define ASSERT(expr, ...) {\
    if (!(expr)) {\
        fprintf(stderr, "%s [%s:%d] \033[91m",\
						__FILE__, __func__, __LINE__);\
        fprintf(stderr, __VA_ARGS__);\
        fprintf(stderr, "\033[00m\n");\
        exit(-1);\
    }\
}

#endif // AZZERT_H
