
CROSS_COMPILE ?= riscv64-unknown-elf-

riscv_march:=rv64imac_zicsr
riscv_mabi:=lp64
arch-cflags = -mcmodel=medany -march=$(riscv_march) -mstrict-align \
	-mabi=$(riscv_mabi)