all: checker.cpp generator.cpp merger.cpp
	g++ checker.cpp -o checker
	g++ generator.cpp -o gen
	g++ merger.cpp -o merger

checker: checker.cpp
	g++ checker.cpp -o checker

gen: generator.cpp
	g++ generator.cpp -o gen

merger: merger.cpp
	g++ merger.cpp -o merger

clean:
	rm -f *.o
	rm -f gen
	rm -f merger
	rm -f checker
