OBJS = main.o omf.o handle.o map.o
CXX = clang++
CXXFLAGS = -Wall -std=c++11

all: regs

regs: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ -largp $^

%.o: %.cc
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f regs $(OBJS)
