BIN = bin
PROGNAME = 
OUT = lib/libmatrices.a
CC = g++
ODIR = obj
SDIR = src
INC = -Iinclude
LIB = -Llib
LIBMAT = -lmatrices
CFLAGS = -Wall -std=c++20
RUNS = runs

_OBJS = matrices/Matrices.o
OBJS = $(patsubst %, $(ODIR)/%, $(_OBJS))

$(ODIR)/%.o: $(SDIR)/%.cpp
	$(CC) -c $(INC) -o $@ $< $(CFLAGS)

$(OUT): $(OBJS)
	ar rvs $(OUT) $^

%.prog: $(SDIR)/%.cpp
	mkdir -p $(BIN)
	$(CC) -o $(patsubst %.prog, $(BIN)/%, $@) $< $(INC) $(CFLAGS)

all:
	mkdir -p ./$(ODIR)/matrices
	make $(ODIR)/matrices/Matrices.o
	make $(OUT)

.PHONY: clean

clean:
	rm -rf $(ODIR)/matrices/*.o $(BIN)/*

cleanruns:
	rm -rf $(RUNS)/*

cleanlib:
	rm -rf $(OUT)
