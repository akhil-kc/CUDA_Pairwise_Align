SRC_DIR = src
OBJ_DIR = obj
CC     = nvcc
CFLAGS = -O3 -gencode=arch=compute_20,code=compute_20

all: clean main 

main: main.o dna.o SWUtils.o 
	$(CC) $(CFLAGS) $(OBJ_DIR)/main.o $(OBJ_DIR)/dna.o $(OBJ_DIR)/SWUtils.o -o CUDAAlign

main.o: $(SRC_DIR)/main.cu
	$(CC) $(CFLAGS) -c $(SRC_DIR)/main.cu -o $(OBJ_DIR)/main.o
dna.o: $(SRC_DIR)/dna.cpp
	$(CC) $(CFLAGS) -c $(SRC_DIR)/dna.cpp -o $(OBJ_DIR)/dna.o
SWUtils.o: $(SRC_DIR)/SWUtils.cu
	 $(CC) $(CFLAGS) -c $(SRC_DIR)/SWUtils.cu -o $(OBJ_DIR)/SWUtils.o
clean:
	rm -f $(OBJ_DIR)/*.o
	rm -f *CUDAAlign

