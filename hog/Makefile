include ../common/make.def

OPENCV_LIBS		= -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_ml -lopencv_video -lopencv_features2d -lopencv_calib3d -lopencv_objdetect -lopencv_stitching -lopencv_imgcodecs -lopencv_flann
BIN			= personDetector
HOG			= hog
TDG			= -DTDG -fopenmp
OPENCV_L		= -L$(OPENCV_PATH)/lib -Wl,-rpath,$(OPENCV_PATH)/lib
OPENCV_I		= -I$(OPENCV_PATH)/include/opencv4/

all: $(BIN)_vanilla $(BIN)_serial $(BIN)_record $(BIN)_for

$(BIN)_serial: $(BIN).cpp
	$(CC) $(CFLAGS) -c $(HOG).c -I$(UTILS_INC)
	$(CCX) $(OPENCV_I) $(CFLAGS) $^ -o $@ $(HOG).o $(OPENCV_L) $(OPENCV_LIBS) -I$(UTILS_INC)

$(BIN)_vanilla: $(BIN).cpp
	$(CC) $(CFLAGS)  $(OMP) -c $(HOG).c  -I$(UTILS_INC)
	$(CCX) $(OPENCV_I) $(CFLAGS)  $(OMP) $^ -o $@ $(HOG).o $(OPENCV_L) $(OPENCV_LIBS) -I$(UTILS_INC)

$(BIN)_record: $(BIN).cpp
	$(CC) $(CFLAGS)  $(OMP) $(TDG) -c $(HOG).c -o $(HOG)_record.o -I$(UTILS_INC)
	$(CCX) $(OPENCV_I) $(CFLAGS) $(OMP) $(TDG) -L$(TDG_LIB) $^ -o $@ $(HOG)_record.o $(OPENCV_L) $(OPENCV_LIBS) -I$(UTILS_INC)

$(BIN)_for: $(BIN).cpp
	$(CC) $(CFLAGS)  $(OMP) $(TDG) -DOMP=1 -c $(HOG)_for.c -I$(TDG_INC) -I$(UTILS_INC)
	$(CCX) $(OPENCV_I) $(CFLAGS)  $(OMP) $^ -o $@ $(HOG)_for.o $(OPENCV_L) $(OPENCV_LIBS) -I$(TDG_INC) -I$(UTILS_INC)

clean:
	rm -f *.o $(BIN)_vanilla $(BIN)_serial $(BIN)_record $(BIN)_for
	rm -rf dot json
