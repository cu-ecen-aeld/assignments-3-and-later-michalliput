CC=gcc
CFLAGS=-Wall -V

#ifndef CROSS_COMPILE
#CROSS_COMPILE=aarch64-none-linux-gnu-

all: clean writer

writer: writer.c
	$(CROSS_COMPILE)$(CC) -o $@ writer.c

clean:
	rm -f writer
