include ../common/make.def

CFLAGS	+= -ffast-math
LIBS = -lm -lpthread

BIN		= dot_product_serial dot_product_vanilla dot_product_record dot_product_for

all: $(BIN)

kernels.o: kernels.c
	$(CC) $(CFLAGS) -I$(MKL_INC) -DMKL_ILP64 -m64 $^ -c -o $@ -L$(MKL_LIB)

dot_product_serial : dotp-omp.c main-omp.c kernels.o
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS) -I$(UTILS_INC)

dot_product_vanilla: dotp-omp.c main-omp.c kernels.o
	$(CC) $(OMP) $(CFLAGS) $^ -o $@ $(LIBS) -I$(UTILS_INC)

dot_product_record: dotp-omp.c main-omp.c kernels.o
	$(CC) $(OMP) $(CFLAGS) $^ -o $@ $(LIBS) $(TDG) -L$(TDG_LIB) -I$(UTILS_INC)

dot_product_for: dotp-omp.c main-omp-for.c kernels.o
	$(CC) $(OMP) $(CFLAGS) $^ -o $@ $(LIBS) -I$(TDG_INC) -I$(UTILS_INC)

clean:
	rm -f $(BIN) safetycc_dotp-omp.c safetycc_main-omp.c kernels.o
