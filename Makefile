CC=clang
CFLAGS=-Wall

all: 2mg omf regs

2mg: 2mg.o
	$(CC) $(CFLAGS) -o $@ -largp $^

omf: omf.o parser.o
	$(CC) $(CFLAGS) -o $@ -largp $^

regs: regs.o map.o scan.o parser.o disasm.o iigs.o
	$(CC) $(CFLAGS) -o $@ -largp $^

iigs.c: iigs.dat
	xxd -i $< $@

iigs.dat: docmaker/docmaker iigs
	./docmaker/docmaker iigs

docmaker/docmaker:
	$(MAKE) -C docmaker

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

clean:
	rm -f *.o 2mg omg regs
