include ../common/make.def

PREFIX = src
LIBS = -lm
BIN = nbody

SRC = $(PREFIX)/util.c $(PREFIX)/kernel.c

all: $(BIN)_serial $(BIN)_vanilla $(BIN)_record $(BIN)_for

$(BIN)_serial: $(SRC) $(PREFIX)/main.c
	$(CC) $(OMP) $(CFLAGS) -o $@ $^ -g $(LIBS) -I$(UTILS_INC)

$(BIN)_record: $(SRC) $(PREFIX)/main.c
	$(CC) $(OMP) $(CFLAGS) $(TDG) $^ -o $@ -g $(LIBS) -L$(TDG_LIB) -I$(UTILS_INC)

$(BIN)_vanilla: $(SRC) $(PREFIX)/main.c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -g $(LIBS) -I$(UTILS_INC)

$(BIN)_for: $(SRC) $(PREFIX)/main_for.c
	$(CC) $(CFLAGS) $(OMP) $^ -o $@ -g $(LIBS) -I$(TDG_INC) -I$(UTILS_INC)

.PHONY: clean

clean:
	rm -f $(BIN)_serial $(BIN)_record $(BIN)_vanilla nbody_out.xyz $(BIN)_for
