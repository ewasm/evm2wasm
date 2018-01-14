.POSIX:
.SUFFIXES:
CC = gcc
CFLAGS = -Wall -Werror -O2 -pedantic
LDFLAGS = -shared -fPIC -lm

all: gadgets.o evm2wast.o
	$(CC) -o evm2wasm.so evm2wast.o $(LDFLAGS)

evm2wast.o: evm2wast.c
	$(CC) -o evm2wast.o -c evm2wast.c $(CFLAGS) $(LDFLAGS)

gadgets.o: gadgets
	$(CC) -c -o gadgets.o gadgets.c

lint:
	indent *.c
	indent *.h

clean:
	rm *.o *.so

gadgets:
	$(shell ./gen_gadgets.sh)
