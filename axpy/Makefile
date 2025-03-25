CC = $(OMP_PATH)/bin/clang
CFLAGS = -O3 -g
OMP = -fopenmp
TDG = -DTDG -fopenmp
BIN = axpy
all: $(BIN)_serial $(BIN)_vanilla $(BIN)_record $(BIN)_for
TDG_LIB = $(OMP_PATH)
TDG_INC = $(OMP_PATH)/projects/openmp/runtime/src/

$(BIN)_serial: $(BIN).c
	$(CC) $(CFLAGS) $^ -o $@

$(BIN)_vanilla: $(BIN).c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -I$(TDG_INC)

$(BIN)_record: $(BIN).c
	$(CC) $(TDG) $(CFLAGS) $(OMP) $^ -o $@ -L$(TDG_LIB) -I$(TDG_INC)

$(BIN)_for: $(BIN)_for.c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -I$(TDG_INC)

clean:
	rm -f $(BIN)_serial $(BIN)_record $(BIN)_vanilla $(BIN)_for
