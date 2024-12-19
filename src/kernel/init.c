#include "platform.h"

__attribute__ ((aligned (16))) char stack0[4096];

void
main(void)
{
    platform_init();
    while(1);
    // consoleinit();
    // printfinit();
    // printf("\n");
    // printf("xv6 kernel is booting\n");
    // printf("\n");
    // kinit();         // physical page allocator
    // kvminit();       // create kernel page table
    // kvminithart();   // turn on paging
    // procinit();      // process table
    // trapinit();      // trap vectors
    // trapinithart();  // install kernel trap vector
    // plicinit();      // set up interrupt controller
    // plicinithart();  // ask PLIC for device interrupts
}
