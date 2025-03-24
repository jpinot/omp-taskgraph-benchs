CC		= $(OMP_PATH)/bin/clang
CFLAGS		= -O3 -g -ffast-math
OMP		= -fopenmp
TDG		= -DTDG -fopenmp
TDG_LIB		= $(OMP_PATH)
TDG_INC = $(OMP_PATH)/projects/openmp/runtime/src/
LIBS = -lm -lpthread
MKL_LIB = $(MKL_PATH)/lib/intel64 -Wl,-rpath,$(MKL_PATH)/lib/intel64
MKL_INC = $(MKL_PATH)/include

BIN		= dot_product_serial dot_product_vanilla dot_product_record dot_product_for

all: $(BIN)

kernels.o: kernels.c
	$(CC) $(CFLAGS) -I$(MKL_INC) -DMKL_ILP64 -m64 $^ -c -o $@ -L$(MKL_LIB)

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
