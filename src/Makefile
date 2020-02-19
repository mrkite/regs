OBJS = main.o omf.o handle.o map.o disasm.o api.o
CXX = clang++
CXXFLAGS = -Wall -std=c++11

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	LDFLAGS = -largp
endif

all: regs

regs: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ $(LDFLAGS) $^

%.o: %.cc
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f regs $(OBJS)
