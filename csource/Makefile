PREFIX ?= .
SRC     = src/main.c deps/list/list.c deps/list/list_iterator.c deps/hexString/hexString.c 
CC      = gcc

trans.js: $(SRC)
	$(CC) $(SRC) -o $@

clean:
	rm -r trans.js
