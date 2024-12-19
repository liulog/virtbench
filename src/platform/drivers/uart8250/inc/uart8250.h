#ifndef __UART_8250_H__

#include <stdint.h>
typedef uint32_t u32;
typedef uint16_t u16;

void uart8250_enable_rx_int(void);

void uart8250_putc(char ch);

int uart8250_getc(void);

int uart8250_init(unsigned long base, u32 in_freq, u32 baudrate, u32 reg_shift,
		  u32 reg_width);

#endif