OBJS = main.o omf.o handle.o map.o disasm.o api.o scanner.o
OBJS2mg = 2mg.o handle.o
CXX = clang++
CXXFLAGS = -g -Wall -std=c++11

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	LDFLAGS = -largp
endif

all: ../regs ../2mg

../2mg: $(OBJS2mg)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ $(LDFLAGS) $^

../regs: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ $(LDFLAGS) $^

%.o: %.cc
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f ../regs ../2mg $(OBJS) $(OBJS2mg)
