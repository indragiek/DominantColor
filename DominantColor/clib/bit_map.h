#ifndef _BIT_MAP_H
#define _BIT_MAP_H
	#include "defs.h"

	// The idea is that every element present has a unique
	// bit index as well as bucket e.g number 98
	// maps to bucket 98/32 = 3 and bit 98 % 32 = 2
	typedef struct {
		size_t size;
		size_t baseBits;
		size_t capacity;
		unsigned int allocd:1;
		unsigned int buckets[];
	} BitMap;

	BitMap *newBitMap(const size_t n);
	BitMap *freeBitMap(BitMap *bm);

	Bool exists(BitMap *bm, const unsigned int hash);
	BitMap *appendToBitMap(BitMap *bm, const unsigned int v);

	BitMap *add(BitMap *bm, const unsigned int hash);
	BitMap *pop(BitMap *bm, const unsigned int hash);
	BitMap *upsize(BitMap *bm, const size_t n);

#endif // _BIT_MAP_H
