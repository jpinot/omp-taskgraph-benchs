include ../common/make.def

BIN = axpy
all: $(BIN)_serial $(BIN)_vanilla $(BIN)_record $(BIN)_for

$(BIN)_serial: $(BIN).c
	$(CC) $(CFLAGS) $^ -o $@ -I$(UTILS_INC)

$(BIN)_vanilla: $(BIN).c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -I$(UTILS_INC)

$(BIN)_record: $(BIN).c
	$(CC) $(TDG) $(CFLAGS) $(OMP) $^ -o $@ -L$(TDG_LIB) -I$(TDG_INC) -I$(UTILS_INC)

$(BIN)_for: $(BIN)_for.c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -I$(TDG_INC) -I$(UTILS_INC)

clean:
	rm -f $(BIN)_serial $(BIN)_record $(BIN)_vanilla $(BIN)_for
