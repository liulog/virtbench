
.section ".boot", "ax"
.globl _start
_start:
        # set up a stack for C.
        # stack0 is declared in start.c.
        la sp, stack0
        # jump to start() in start.c
        call main
spin:
        j spin