include ../common/make.def

LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lm -lpthread
BIN = cholesky
all: $(BIN)_vanilla $(BIN)_serial $(BIN)_record $(BIN)_for

$(BIN)_serial: $(BIN).c
	$(CC) $(CFLAGS) -I$(MKL_INC) $^ -DSEQ -o $@ -L$(MKL_LIB) $(LIBS) -I$(TDG_INC) -I$(UTILS_INC)

$(BIN)_record: $(BIN).c
	$(CC) $(CFLAGS) -I$(MKL_INC) $(OMP) $(TDG) $^ -o $@ -L$(MKL_LIB) -L$(TDG_LIB) $(LIBS) -I$(TDG_INC) -I$(UTILS_INC)

$(BIN)_vanilla: $(BIN).c
	$(CC) $(CFLAGS) -I$(MKL_INC) $(OMP) $^ -o $@ -L$(MKL_LIB) $(LIBS) -I$(TDG_INC) -I$(UTILS_INC)

$(BIN)_for: $(BIN)_for.c
	$(CC) $(CFLAGS) -I$(MKL_INC) $(OMP) $^ -o $@ -L$(MKL_LIB) $(LIBS) -I$(TDG_INC) -I$(UTILS_INC)

clean:
	rm -f *.o $(BIN)_serial $(BIN)_record $(BIN)_vanilla  safetycc_cholesky.c $(BIN)_for

