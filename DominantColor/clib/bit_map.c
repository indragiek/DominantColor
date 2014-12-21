// Bit map implementation
// Author: Emmanuel Odeke <odeke@ualberta.ca>

// Idea: Every element with a hash has a unique
// bit index as well as bucket e.g number 98
// maps to bucket 98/32 = 3 and bit 98 % 32 = 2
// Will be useful for space efficient memoization
// and membership checks.

#include <stdio.h>
#include <stdlib.h>

#include "defs.h"
#include "azzert.h"
#include "bit_map.h"

BitMap *newBitMap(const size_t n) {
	size_t i;
	BitMap *bm = malloc(sizeof(*bm) + (sizeof(unsigned int) * n));
	ASSERT(bm != NULL, "Run out of memory!");

	bm->allocd = 1;
	bm->size = bm->capacity = n;
	bm->baseBits = 8 * sizeof(bm->baseBits);
	for (i = 0; i < bm->capacity; ++i) {
		bm->buckets[i] = 0;
	}

	return bm;
}

BitMap *freeBitMap(BitMap *bm) {
	if (bm != NULL && bm->allocd) {
		bm->allocd = 0;
		free(bm);
		bm = NULL;
	}

	return bm;
}

BitMap *upsize(BitMap *bm, const size_t n) {
	size_t i, sz;
	BitMap *tmp;

	if (bm == NULL) {
		bm = newBitMap(n + 1); // Magic start value
	} else if (!bm->allocd)
		return NULL;

	if (bm->size >= bm->capacity) {
		sz = bm->size + n + 1;
		tmp = realloc(bm, sizeof(*bm) + (sizeof(unsigned int) * sz));
		if (tmp == NULL) {
			goto done;
		}

		bm = tmp;
	}

	for (i = bm->size; i < sz; ++i) {
		bm->buckets[i] = 0;
	}

	bm->size = sz;

done:
	return bm;
}

static Bool _resolve(BitMap *bm, const unsigned int hash,
				unsigned int *bucketSav, unsigned int *bIndexSav) {
	Bool overflow;
	*bucketSav = hash / bm->baseBits;
	overflow = (*bucketSav >= bm->size);
	*bIndexSav = hash % bm->baseBits;
	return overflow;
}

Bool exists(BitMap *bm, const unsigned int hash) {
	unsigned int bucket = 0;
	unsigned int bIndex = 0;

	if (bm == NULL)
		return False;

 	_resolve(bm, hash, &bucket, &bIndex);
	if (!bm->buckets[bucket])
		return False;

	return 0 != bm->buckets[bucket] >> bIndex;
}

static BitMap *_mutate(BitMap *bm,
				 		const unsigned int hash, Bool popOp) {
	Bool overflow;
	unsigned int *ref;
	unsigned int bucket = 0;
	unsigned int bIndex = 0;

	if (bm == NULL)
		return NULL;

	overflow = _resolve(bm, hash, &bucket, &bIndex);
	if (overflow) {
		if (popOp)
			return bm;
	
		bm = upsize(bm, bucket - bm->size);	
	}
	ref = &bm->buckets[bucket];

	if (popOp)
		*ref = *ref & (*ref ^ (1 << bIndex));
	else
		*ref |= 1 << bIndex;
	return bm;
}

BitMap *pop(BitMap *bm, const unsigned int hash) {
	return _mutate(bm, hash, True);
}

BitMap *add(BitMap *bm, const unsigned int hash) {
	return _mutate(bm, hash, False);
}
