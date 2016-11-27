#include <driver_types.h>

class cudaTimer {
private:
    cudaEvent_t _start;
    cudaEvent_t _stop;

public:
    cudaTimer();

    ~cudaTimer();

    void start();

    void stop();

    float getElapsedTimeMillis();
};

struct CUDAcard{
        char name[256];
        int cardNumber;
        int cardsInSystem;
        int major;
        int minor;
        unsigned long long globalMem;
        int maxThreadsPerBlock;
        int SMs;
        int cudaCores;
} ;

CUDAcard findBestDevice();

void printCardInfo(CUDAcard gpu);

void safeAPIcall(cudaError_t err, int line);

