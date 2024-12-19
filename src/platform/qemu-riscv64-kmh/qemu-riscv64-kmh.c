
#include "uart8250.h"
#include "platform.h"
#include "qemu-riscv64-kmh.h"

void platform_init(){
    uart8250_init(UARTADDR, 0, UARTBAUD, 2, 4);
    uart8250_putc('a');
}