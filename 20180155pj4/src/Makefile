all: map.h map.cpp pathfinder.cpp mapgen.cpp
	g++ map.h
	g++ pathfinder.cpp map.cpp -o pathfinder
	g++ mapgen.cpp map.cpp -o mapgen

pathfinder : map.h map.cpp pathfinder.cpp mapgen.cpp
	g++ map.h
	g++ pathfinder.cpp map.cpp -o pathfinder

clean:
	rm -f *.o
	rm -f *.gch
	rm -f pathfinder
	rm -f mapgen

