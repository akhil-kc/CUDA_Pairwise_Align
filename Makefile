FLAGS = -arch=sm_20

SRC_DIR = .
SRC := $(wildcard $(SRC_DIR)/*.cpp $(SRC_DIR)/*.cu)
HEADERS := $(wildcard $(SRC_DIR)/*.h $(SRC_DIR)/*.cuh)

SWalign: $(HEADERS) $(SRC)
	nvcc -o $@ $(SRC) $(FLAGS)

debug: $(HEADERS) $(SRC)
	nvcc -o SWalign $(SRC) $(FLAGS) -G

