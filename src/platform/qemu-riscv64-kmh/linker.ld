
OUTPUT_ARCH( "riscv" )
ENTRY( _start )

/* MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 2048M
} */

SECTIONS
{
    . = 0x80200000;

	.boot : {
		*(.boot)
	}

    .text : {
        *(.text .text.*)
    }

    .rodata : {      /* for gcc>=13, (READONLY) is needed */
        . = ALIGN(16);
        *(.srodata .srodata.*) /* do not need to distinguish this from .rodata */
        . = ALIGN(16);
        *(.rodata .rodata.*)
    }

    .data : {
        . = ALIGN(16);
        *(.sdata .sdata.*)  /* do not need to distinguish this from .data */
        . = ALIGN(16);
        *(.data .data.*)
    }

    . = ALIGN(4K);
    .benchmarks : {			/* benchmarks section */
        _sbenchmarks = .;
        KEEP(*(.benchmarks));
        _ebenchmarks = .;
    }

    .bss : {
        . = ALIGN(16);
        *(.sbss .sbss.*) /* do not need to distinguish this from .bss */
        . = ALIGN(16);
        *(.bss .bss.*)
    }

    PROVIDE(end = .);
}
