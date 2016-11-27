#include <stdio.h>
#include <stdlib.h>
#include "dna.h"
//#include "Alignment.cu"
#include <iostream>
#include "SWUtils.h"
//#include "KernelUtil.cu"
#include<cuda.h>
#include <cuda_runtime_api.h>
using namespace std;
//#include "KernelUtil.cu"
//#include "Alignment.cu"
#include <iostream>
#include<cuda.h>
#include <cuda_runtime_api.h>
//define the chunk sizes that each threadblock will work on
#define BLKXSIZE 32
#define BLKYSIZE 4
#define BLKZSIZE 4

// for cuda error checking
#define cudaCheckErrors(msg) \
    do { \
        cudaError_t __err = cudaGetLastError(); \
        if (__err != cudaSuccess) { \
            fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n", \
                msg, cudaGetErrorString(__err), \
                __FILE__, __LINE__); \
            fprintf(stderr, "*** FAILED - ABORTING\n"); \
            return 1; \
        } \
    } while (0)



__device__ int maxScore2(int score1,int score2) {
        return ((score1>score2)?score1:score2);
}

__device__ int maxScore3(int score1,int score2,int score3) {
        return ((score1>score2)?((score1>score3)?score1:score3):((score2>score3)?score2:score3));
}

__global__ void parallel_scan(DNA sequences[2],int *score,int *prev_row,unsigned iteration)
{
    unsigned idx = blockIdx.x*blockDim.x + threadIdx.x;
    unsigned idy = blockIdx.y*blockDim.y + threadIdx.y;
    int xLen=sequences[0].seq_length;
    int yLen=sequences[1].seq_length;
    unsigned index= idx + (xLen * idy );
    if (index < xLen){
        score[index]=(int)maxScore2(prev_row[index-1]+5,prev_row[index]-3);
      }
}

int main(int argc, char *argv[])
{
    DNA *sequences=new DNA[2];
    sequences[0].read_file(argv[1]);
    sequences[1].read_file(argv[2]);
    //Sequence 1 along the x-axis should always be greater
    if (sequences[0].seq_length<sequences[1].seq_length)
    {
	DNA temp;
	temp.seq_string=sequences[0].seq_string;
	temp.seq_length=sequences[0].seq_length;
	sequences[0].seq_string=sequences[1].seq_string;
	sequences[0].seq_length=sequences[1].seq_length;
	sequences[1].seq_string=temp.seq_string;
	sequences[1].seq_length=temp.seq_length;
     }
    printf("\n Sequence 1: %s \t Length: %d",sequences[0].seq_string,sequences[0].seq_length);
    printf("\n Sequence 2: %s \t Length: %d",sequences[1].seq_string,sequences[1].seq_length);
    const int nx = sequences[0].seq_length;
    const int ny = sequences[1].seq_length;
    unsigned size=nx*ny;
    int *c,*temp; 
    int *d_c;  
    int *final[ny];
cout<<"\n Before malloc";
    if ((c = (int *)malloc((nx*ny)*sizeof(int))) == 0) {fprintf(stderr,"malloc1 Fail \n"); return 1;}
cout<<"\n After malloc";
    for(int i=0;i<nx;i++)
	final[i][0]=(-i);
    for(int i=0;i<ny;i++)
	final[0][i]=(-i);
cout<<"\n After Init";
    
    
    cudaMalloc((void **) &d_c, (nx)*sizeof(int));
    cudaCheckErrors("Failed to allocate device buffer");
    for (unsigned iteration=1;iteration<ny;iteration++)
    {
	memcpy(final[iteration-1],temp,nx);
    	parallel_scan<<<(nx/512),512>>>(sequences,d_c,temp,iteration);
    	cudaCheckErrors("Kernel launch failure");
    	cudaMemcpy(c, d_c, ((nx)*sizeof(int)), cudaMemcpyDeviceToHost);
    	cudaCheckErrors("CUDA memcpy failure");
	memcpy(final[iteration],c,nx);
    }
    free(c);
    cudaFree(d_c);
    cudaCheckErrors("cudaFree fail");
    cout<<"\n\nSUCCESS";
    return 0;
}
