OBJS = docmaker.o parser.o compiler.o file.o avl.o output.o
CXX = clang++
CXXFLAGS = -Wall -std=c++11

all: docmaker

docmaker: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ $^

%.o: %.cc
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f docmaker $(OBJS)
