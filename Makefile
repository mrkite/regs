CC=clang
CFLAGS=-Wall

all: 2mg regs dsk

2mg: FORCE
	$(MAKE) -C src ../2mg

dsk: FORCE
	$(MAKE) -C src ../dsk

regs: FORCE src/iigs.h
	$(MAKE) -C src ../regs

src/iigs.h: iigs.dat
	xxd -i $< $@

iigs.dat: docmaker/docmaker iigs
	./docmaker/docmaker iigs

docmaker/docmaker:
	$(MAKE) -C docmaker

FORCE:

clean:
	rm -f *.o
	$(MAKE) -C docmaker clean
	$(MAKE) -C src clean
