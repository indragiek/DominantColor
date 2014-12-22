CC:=gcc
CFLAGS:=-Wextra -Wall
LIBS:=-lm # For math
RM:=rm -f

%.o:	%.c
	$(CC) $(CFLAGS) -c $^ -o $@ $(LIBS)

%:
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

alt_lib_test:   alt_lib_test.c alt_lib.o

clean:
	$(RM) *.o *.so
