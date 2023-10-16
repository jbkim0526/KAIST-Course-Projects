ish: ish.o dynarray.o
	gcc209 -D_GNU_SOURCE ish.o dynarray.o -o ish
dynarray.o: dynarray.c dynarray.h
	gcc209 -D_GNU_SOURCE -c dynarray.c dynarray.h
ish.o: ish.c dynarray.h
	gcc209 -D_GNU_SOURCE -c ish.c dynarray.h
