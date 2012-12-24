# Makefile Finger Lake Instrumentation python module
PYVERSION=$(shell python -c "import sys; print sys.version[:3]")
PYPREFIX=$(shell python -c "import sys; print sys.prefix")
INCLUDES=-I$(PYPREFIX)/include/python$(PYVERSION)
LIBS=-L../libfli-1.104/

pyfli: pyfli.o
	gcc -o pyfli.so $^ $(LIBS) -lpython$(PYVERSION) -lm -lfli -shared

pyfli.s: pyfli.c
	gcc -c $^ $(INCLUDES) -fPIC -S $(CFLAGS)

pyfli.o: pyfli.c
	gcc -c $^ $(INCLUDES) -fPIC

pyfli.c: pyfli.pyx libfli.pxd
	@cython -X embedsignature=True pyfli.pyx

all: pyfli

clean:
	@rm -f *.{so,o,c}
