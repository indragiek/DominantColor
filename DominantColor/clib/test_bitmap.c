#include <stdio.h>
#include <stdlib.h>

#include "azzert.h"
#include "bit_map.h"

int main() {
	int i;
	BitMap *bm = newBitMap(100);

	ASSERT(bm->size == 100, "Expected 10");
	bm = add(bm, 1009);

	ASSERT(exists(bm, 1009), "1009 must exist!");
	ASSERT(!exists(bm, 1019), "1019 doesn't exist!");

	// Testing out if multiple pops trip setup out
	for (i = 0; i < 10; i++) {
		bm = pop(bm, 1009);
		ASSERT(!exists(bm, 1009), "1009 just got popped!");
		ASSERT(!exists(bm, 1009), "1009 just got popped!");
		ASSERT(!exists(bm, 1009), "1009 just got popped!");
	}

	bm = freeBitMap(bm);
	ASSERT(bm == NULL, "Expected bm to have been set to NULL!");

	return 0;
}
