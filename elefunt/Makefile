LIB=elefunt
FFLAGS=-O
OBJ = \
	asin.o	\
	atan.o	\
	dasin.o	\
	datan.o	\
	dexp.o	\
	dlog.o	\
	dmachar.o	\
	dpower.o	\
	dsin.o	\
	dsinh.o	\
	dsqrt.o	\
	dtan.o	\
	dtanh.o	\
	exp.o	\
	machar.o	\
	power.o	\
	sin.o	\
	sinh.o	\
	sqrt.o	\
	tan.o	\
	tanh.o	\
	alog.o
lib$(LIB).a:	$(OBJ)
	ar ru lib$(LIB).a $?
	ranlib lib$(LIB).a

install:	lib$(LIB).a
	ln -s /netlib/netlib/elefunt/lib$(LIB).a /usr/local/lib
	rm *.o

test: test.o
	f77 test.o -l$(LIB)
	time a.out
