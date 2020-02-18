OBJS = main.o omf.o handle.o map.o
CXX = clang++
CXXFLAGS = -g -Wall -std=c++11
LDFLAGS = -largp

all: regs

regs: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ $^

%.o: %.cc
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f regs $(OBJS)
