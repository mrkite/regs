CC=clang
CFLAGS=-Wall

all: 2mg regs

2mg: 2mg.o
	$(CC) $(CFLAGS) -o $@ -largp $^

regs: src/iigs.h
	$(MAKE) -C src

src/iigs.h: iigs.dat
	xxd -i $< $@

iigs.dat: docmaker/docmaker iigs
	./docmaker/docmaker iigs

docmaker/docmaker:
	$(MAKE) -C docmaker

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

clean:
	rm -f *.o 2mg regs
	$(MAKE) -C docmaker clean
	$(MAKE) -C src clean
