#!/bin/bash

export CROSS_COMPILE=riscv64-unknown-linux-gnu-

make all

# make build
# 
# cd ~/hypervisor/hvisor-1core

# hvisor
# make all LOG=WARN ARCH=riscv64 FEATURES=kmh_v2_1core

cd ~/hypervisor/opensbi-1.5.1

# make clean
# make -j8 ARCH=riscv PLATFORM=generic FW_PAYLOAD_PATH=/home/jingyu/hypervisor/HyperBench4RV64/riscv64/build/demo.bin FW_FDT_PATH=/home/jingyu/hypervisor/xiangshan/opensbi-devel/kmh-v2-1core.dtb

make clean
make -j8 ARCH=riscv PLATFORM=generic FW_PAYLOAD_PATH=/home/jingyu/hypervisor/virtbench/bin/qemu-riscv64-kmh/virtbench.bin FW_FDT_PATH=/home/jingyu/hypervisor/xiangshan/opensbi-devel/kmh-v2-1core.dtb

/home/jingyu/hypervisor/xiangshan/qemu-devel/build/qemu-system-riscv64 -nographic \
    -M bosc-kmh -smp 1 -m 4G \
    -bios ~/hypervisor/opensbi-1.5.1/build/platform/generic/firmware/fw_payload.bin
