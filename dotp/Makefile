CC		= $(OMP_PATH)/bin/clang
CFLAGS		= -O3 -g -ffast-math
OMP		= -fopenmp
TDG		= -DTDG -fopenmp
TDG_LIB		= $(OMP_PATH)
TDG_INC = $(OMP_PATH)/projects/openmp/runtime/src/
# LIBS		= -lrt  -L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
LIBS = -lmkl_sequential -lmkl_core -lm -lmkl_rt -lpthread
MKL_LIB = $(MKL_PATH)/lib/intel64 -Wl,-rpath,$(MKL_PATH)/lib/intel64
MKL_INC = $(MKL_PATH)/include

BIN		= dot_product_serial dot_product_vanilla dot_product_record dot_product_for

all: $(BIN)

kernels.o: kernels.c
	# $(CC) $(CFLAGS) -I$(MKL_INC) -DMKL_ILP64 -m64 -I${MKLROOT}/include $^ -c -o $@ -L$(MKL_LIB)
	$(CC) $(CFLAGS) -I$(MKL_INC) $^ -DSEQ -o $@
	# $(CC) $(CFLAGS) -I$(MKL_INC) $^ -DSEQ -o $@ -L$(MKL_LIB) -L$(LIBS)

dot_product_serial : dotp-omp.c main-omp.c kernels.o
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

dot_product_vanilla: dotp-omp.c main-omp.c kernels.o
	$(CC) $(OMP) $(CFLAGS) $^ -o $@ $(LIBS)

dot_product_record: dotp-omp.c main-omp.c kernels.o
	$(CC) $(OMP) $(CFLAGS) $^ -o $@ $(LIBS) $(TDG) -L$(TDG_LIB)

dot_product_for: dotp-omp.c main-omp-for.c kernels.o
	$(CC) $(OMP) $(CFLAGS) $^ -o $@ $(LIBS) -I$(TDG_INC)

clean:
	rm -f $(BIN) safetycc_dotp-omp.c safetycc_main-omp.c kernels.o
