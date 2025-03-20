CC = $(OMP_PATH)/bin/clang
CCX = $(OMP_PATH)/bin/clang++
OMP = -fopenmp
# LIBS = -lmkl_sequential -lmkl_core -lm -lmkl_rt -lpthread
LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lm -lpthread
CFLAGS = -O3 -g
BIN = cholesky
TDG = -DTDG -fopenmp
TDG_LIB = $(OMP_PATH)/lib
TDG_INC = $(OMP_PATH)/projects/openmp/runtime/src/
MKL_LIB = $(MKL_PATH)/lib/intel64 -Wl,-rpath,$(MKL_PATH)/lib/intel64
MKL_INC = $(MKL_PATH)/include
#/apps/INTEL/oneapi/2021.3/mkl/2021.3.0/lib/intel64
all: $(BIN)_vanilla $(BIN)_serial $(BIN)_record $(BIN)_for

$(BIN)_serial: $(BIN).c
	$(CC) $(CFLAGS) -I$(MKL_INC) $^ -DSEQ -o $@ -L$(MKL_LIB) $(LIBS) -I$(TDG_INC)

$(BIN)_record: $(BIN).c
	$(CC) $(CFLAGS) -I$(MKL_INC) $(OMP) $(TDG) $^ -o $@ -L$(MKL_LIB) -L$(TDG_LIB) $(LIBS) -I$(TDG_INC)

$(BIN)_vanilla: $(BIN).c
	$(CC) $(CFLAGS) -I$(MKL_INC) $(OMP) $^ -o $@ -L$(MKL_LIB) $(LIBS) -I$(TDG_INC)

$(BIN)_for: $(BIN)_for.c
	$(CC) $(CFLAGS) -I$(MKL_INC) $(OMP) $^ -o $@ -L$(MKL_LIB) $(LIBS) -I$(TDG_INC)

clean:
	rm -f *.o $(BIN)_serial $(BIN)_record $(BIN)_vanilla  safetycc_cholesky.c $(BIN)_for

