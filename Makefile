BIN = bin
PROGNAME = 
OUT = lib/libmatrices.a
CC = g++
ODIR = obj
SDIR = src
INC = -Iinclude
LIB = -Llib
LIBMAT = -Lmatrices
CFLAGS = -Wall
RUNS = runs

_OBJS = matrices/Matrices.o
OBJS = $(patsubst %, $(ODIR)/%, $(_OBJS))

$(ODIR)/%.o: $(SDIR)/%.cpp
	$(CC) -c $(INC) -o $@ $< $(CFLAGS)

$(OUT): $(OBJS)
	ar rvs $(OUT) $^

%.prog: $(SDIR)/%.cpp
	$(CC) -o $(patsubst %.prog, $(BIN)/%, $@) $< $(INC) $(LIB) $(LIBMAT) $(CFLAGS)

.PHONY: clean

clean:
	rm -rf $(ODIR)/*.o $(BIN)/*

cleanruns:
	rm -rf $(RUNS)/*

cleanlib:
	rm -rf $(OUT)
