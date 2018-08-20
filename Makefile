CC=clang
CFLAGS=-Wall

all: 2mg omf regs

2mg: 2mg.o
	$(CC) $(CFLAGS) -o $@ $^

omf: omf.o parser.o
	$(CC) $(CFLAGS) -o $@ $^

regs: regs.o map.o scan.o parser.o disasm.o
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

clean:
	rm -f *.o 2mg omg regs
