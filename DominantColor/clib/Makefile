CC:=gcc
CFLAGS:=-Wextra -Wall -DUNIQ_CENTROIDS
LIBS:=-lm # For math
RM:=rm -f

%.o:	%.c
	$(CC) $(CFLAGS) -c $^ -o $@ $(LIBS)

%:
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

alt_lib_test:   alt_lib_test.c bit_map.o alt_lib.o
test_bitmap:	bit_map.o
test:	kmeans.o

clean:
	$(RM) *.o *.so
