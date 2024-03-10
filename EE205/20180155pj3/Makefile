all: bst.h bst.cpp tester.cpp tester_private.cpp
	g++ bst.h
	g++ tester.cpp bst.cpp -o tester
	g++ tester_private.cpp bst.cpp -o tester_private

clean:
	rm -f *.o
	rm -f *.gch
	rm -f tester
	rm -f tester_private

