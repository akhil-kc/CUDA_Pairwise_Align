#include <cuda.h>
#include <cuda_runtime_api.h>
#include <driver_types.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SWUtils.h"

cudaTimer::cudaTimer() {
        cudaEventCreate(&_start);
        cudaEventCreate(&_stop);
}

cudaTimer::~cudaTimer() {
        cudaEventDestroy(_start);
        cudaEventDestroy(_stop);
}

void cudaTimer::start() {
        cudaEventRecord(_start, 0);
}

void cudaTimer::stop() {
        cudaEventRecord(_stop, 0);
        cudaEventSynchronize(_stop);
}

float cudaTimer::getElapsedTimeMillis() {
        float time;
        cudaEventElapsedTime(&time, _start, _stop);
        return time;
}

void exitWithMsg(const char *msg, int exitCode) {
        printf("ERROR\n");
        printf("%s\n\n", msg);
        exit(exitCode);
}

int _ConvertSMVer2Cores(int major, int minor) {
    typedef struct {
        int SM;
        int Cores;
    } sSMtoCores;

    sSMtoCores nGpuArchCoresPerSM[] = {
        { 0x10,  8 }, // Tesla Generation (SM 1.0) G80 class
        { 0x11,  8 }, // Tesla Generation (SM 1.1) G8x class
        { 0x12,  8 }, // Tesla Generation (SM 1.2) G9x class
        { 0x13,  8 }, // Tesla Generation (SM 1.3) GT200 class
        { 0x20, 32 }, // Fermi Generation (SM 2.0) GF100 class
        { 0x21, 48 }, // Fermi Generation (SM 2.1) GF10x class
        { 0x30, 192}, // Kepler Generation (SM 3.0) GK10x class
        { 0x35, 192}, // Kepler Generation (SM 3.5) GK11x class
        {   -1, -1 }
    };

    int index = 0;

    while (nGpuArchCoresPerSM[index].SM != -1) {
        if (nGpuArchCoresPerSM[index].SM == ((major << 4) + minor))
            return nGpuArchCoresPerSM[index].Cores;

        index++;
    }

    return -1;
}

CUDAcard findBestDevice() {
        int numOfDevices, bestDeviceNumber;

        cudaDeviceProp bestDeviceProps;

        safeAPIcall(cudaGetDeviceCount(&numOfDevices), __LINE__);

        int maxCores = -1;

        for (int i = 0; i < numOfDevices; ++i) {
                cudaDeviceProp currentDeviceProps;
                safeAPIcall(cudaGetDeviceProperties(&currentDeviceProps, i), __LINE__);

                int deviceCores = _ConvertSMVer2Cores(currentDeviceProps.major,
                                currentDeviceProps.minor) * currentDeviceProps.multiProcessorCount;

                if (maxCores < deviceCores) {
                        maxCores = deviceCores;
                        bestDeviceNumber = i;
                        bestDeviceProps = currentDeviceProps;
                }
        }

        if(maxCores < 0 || numOfDevices < 1)
                exitWithMsg("No CUDA capable card detected.", -2);

        CUDAcard gpu;
        gpu.cardNumber = bestDeviceNumber;
        gpu.major = bestDeviceProps.major;
        gpu.minor = bestDeviceProps.minor;
        gpu.cardsInSystem = numOfDevices;
        gpu.maxThreadsPerBlock = bestDeviceProps.maxThreadsDim[0];
        gpu.SMs = bestDeviceProps.multiProcessorCount;
        gpu.cudaCores = maxCores;
        gpu.globalMem = bestDeviceProps.totalGlobalMem;
        strcpy(gpu.name, bestDeviceProps.name);

        return gpu;
}

void safeAPIcall(cudaError_t err, int line) {
        if(err != cudaSuccess) {
                printf("Error in line %d\n", line);
                exitWithMsg(cudaGetErrorString(err), -2);
        }
}

void printCardInfo(CUDAcard gpu) {
        printf("\t>Name: %s\n", gpu.name);
        printf("\t>CUDA Capability: %d.%d\n", gpu.major, gpu.minor);
        printf("\t>Global memory: %.0f MBytes\n", (float) gpu.globalMem / 1048576.0f);
        printf("\t>Multiprocessors: %d\n", gpu.SMs);
        printf("\t>CUDA cores: %d\n", gpu.cudaCores);
}

