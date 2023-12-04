#include <iostream>

__attribute__((visibility("default")))
extern "C" void print()
{
    printf("STATIC_LIB: %s\n",STATIC_LIB);
    double value = 0.8;
    asm volatile("" : : "r,m"(value) : "memory");
    std::cout << "prints:" << value << std::endl;
}
