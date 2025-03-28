include ../common/make.def

CFLAGS += -DVERBOSE
LFLAGS = -lm

BIN= heat
all: $(BIN)_serial $(BIN)_vanilla $(BIN)_record $(BIN)_for

misc.o: misc.c
	$(CC) -c $(CFLAGS) $< -o $@

heat_serial: heat.c misc.o
	$(CC) $(CFLAGS) $+ $(LFLAGS) -o $@ -I$(UTILS_INC)

heat_for: heat_for.c misc.o
	$(CC) $(OMP) $(CFLAGS) $+ $(LFLAGS) -o $@ -I$(TDG_INC) -I$(UTILS_INC)

heat_serial_blocked: heat.c solver.c misc.o
	$(CC) $(CFLAGS) $+ $(LFLAGS) -o $@ -I$(UTILS_INC)

heat_record: heat.c misc.o
	$(CC) $(CFLAGS) $(OMP) $^ $(TDG) -o $@ $(LFLAGS) -L$(TDG_LIB) -I$(TDG_INC) -I$(UTILS_INC)

heat_vanilla: heat.c misc.o
	$(CC) $(OMP) $(CFLAGS) $+ $(LFLAGS) -o $@ -L$(TDG_LIB) -I$(TDG_INC) -I$(UTILS_INC)

.PHONY: clean
clean:
	rm -fr *.o $(BIN) *ppm tdg.dot tdg.c *_tdg.c
