CC = $(OMP_PATH)/bin/clang
PREFIX = src
OMP = -fopenmp
CFLAGS = -O3 -g
LIBS = -lm
TDG = -DTDG -fopenmp
TDG_LIB = $(OMP_PATH)/lib
TDG_INC = $(OMP_PATH)/projects/openmp/runtime/src/
BIN = nbody

SRC = $(PREFIX)/util.c $(PREFIX)/kernel.c

all: $(BIN)_serial $(BIN)_vanilla $(BIN)_record $(BIN)_for

$(BIN)_serial: $(SRC) $(PREFIX)/main.c
	$(CC) $(CFLAGS) -o $@ $^ -g $(LIBS) 

$(BIN)_record: $(SRC) $(PREFIX)/main.c
	$(CC) $(OMP) $(CFLAGS) $(TDG) $^ -o $@ -g $(LIBS) -L$(TDG_LIB)

$(BIN)_vanilla: $(SRC) $(PREFIX)/main.c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -g $(LIBS) 

$(BIN)_for: $(SRC) $(PREFIX)/main_for.c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -g $(LIBS) -I$(TDG_INC)

.PHONY: clean

clean:
	rm -f $(BIN)_serial $(BIN)_record $(BIN)_vanilla nbody_out.xyz $(BIN)_for
