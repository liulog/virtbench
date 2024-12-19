
PROJECT_NAME:=virtbench
PLATFORM?=qemu-riscv64-kmh

# Helper functions
define current_directory
$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endef

# Note:
# = define recursive variables
# =: define simple variables
# =+ append to variable
cpp=		$(CROSS_COMPILE)cpp
sstrip= 	$(CROSS_COMPILE)strip
cc=			$(CROSS_COMPILE)gcc
ld= 		$(CROSS_COMPILE)ld
as=			$(CROSS_COMPILE)as
objcopy=	$(CROSS_COMPILE)objcopy
objdump=	$(CROSS_COMPILE)objdump
readelf=	$(CROSS_COMPILE)readelf
size=		$(CROSS_COMPILE)size

# Define all directories
cur_dir:=$(current_directory)
src_dir:=$(cur_dir)/src
arch_dir=$(src_dir)/arch/$(ARCH)
lib_dir=$(src_dir)/lib
kernel_dir=$(src_dir)/kernel
platforms_dir=$(src_dir)/platform
platform_dir=$(platforms_dir)/$(PLATFORM)
driver_dir=$(platforms_dir)/drivers/$(DRIVER)
benchmarks_dir=$(src_dir)/benchmark

# Include Platform and Architecture specific Makefiles
-include $(platform_dir)/platform.mk
-include $(arch_dir)/arch.mk

build_dir:=$(cur_dir)/build/$(PLATFORM)
bin_dir:=$(cur_dir)/bin/$(PLATFORM)

# all source directories, include arch, lib, kernel, platform, driver, benchmarks
src_dirs=$(arch_dir) $(lib_dir) $(kernel_dir) ${benchmarks_dir} \
	$(driver_dir) $(platform_dir) 

# all include directories
inc_dirs:=$(addsuffix /inc, $(src_dirs))

# all build directories
build_dirs:=$(patsubst $(src_dir)%, $(build_dir)%, $(src_dirs) $(inc_dirs))

# all directories
directories:=$(build_dir) $(bin_dir) $(build_dirs)

# Setup list of targets for compilation
targets-y+=$(bin_dir)/$(PROJECT_NAME).elf
targets-y+=$(bin_dir)/$(PROJECT_NAME).bin

# Generated files variables
ld_script:= $(platform_dir)/linker.ld

# Setup list of objects for compilation
-include $(addsuffix /objects.mk, $(src_dirs))

# addprefix for objects
objs-y:=
objs-y+=$(addprefix $(arch_dir)/, $(arch-objs-y))				# all arch-objs-y
objs-y+=$(addprefix $(lib_dir)/, $(lib-objs-y))					# all lib-objs-y
objs-y+=$(addprefix $(kernel_dir)/, $(kernel-objs-y))			# all kernel-objs-y
objs-y+=$(addprefix $(driver_dir)/, $(driver-objs-y))			# all drivers-objs-y
objs-y+=$(addprefix $(platform_dir)/, $(platform-objs-y))		# all platform-objs-y
objs-y+=$(addprefix $(benchmarks_dir)/, $(benchmark-objs-y))	# all benchmark-objs-y

deps+=$(patsubst %.o,%.d,$(objs-y))	                            # all dependencies
objs-y:=$(patsubst $(src_dir)%, $(build_dir)%, $(objs-y))		# all objs-y in build_dir

# Toolchain flags
override CPPFLAGS+=$(addprefix -I, $(inc_dirs)) $(arch-cppflags)

# CFLAGS
cflags_warns:= \
	-Warith-conversion -Wbuiltin-declaration-mismatch \
	-Wcomments  -Wdiscarded-qualifiers \
	-Wimplicit-fallthrough \
	-Wswitch-unreachable -Wreturn-local-addr  \
	-Wshift-count-negative  -Wuninitialized \
	-Wunused -Wunused-local-typedefs  -Wunused-parameter \
	-Wunused-result -Wvla \
	-Wmissing-prototypes -Wmissing-declarations  \
	-Wswitch-default -Wshadow -Wshadow=global \
	-Wcast-qual \
	-Wstrict-prototypes -Wunused-but-set-variable
override CFLAGS+=-O2 -Wall -Werror -Wextra $(cflags_warns) \
	-ffreestanding -std=c11 -fno-pic \
	$(arch-cflags) $(CPPFLAGS)

# LDFLAGS
override LDFLAGS+=-build-id=none -nostdlib $(arch-ldflags)

.PHONY: all
all build: ${targets-y}

# build ELF
$(bin_dir)/$(PROJECT_NAME).elf: $(objs-y)
	@$(ld) $(LDFLAGS) -T$(ld_script) $(objs-y) -o $@
	@$(objdump) -S --wide $@ > $(basename $@).asm
	@$(readelf) -a --wide $@ > $@.txt

# Used for generating dependency files
$(build_dir)/%.d : $(src_dir)/%.[c,S]
	@echo "Creating dependecy	$(patsubst $(cur_dir)/%, %, $<)"
	@$(cc) -MM -MG -MT "$(patsubst %.d, %.o, $@) $@"  $(CPPFLAGS) $< > $@	

# Include all dependencies
# 
-include $(deps)

# Compile source files
$(objs-y):
	@echo "Compiling source	$(patsubst $(cur_dir)/%, %, $<)"
	@$(cc) $(CFLAGS) -c $< -o $@

# Generate binary from ELF
%.bin: %.elf
	@echo "Generating binary	$(patsubst $(cur_dir)/%, %, $@)"
	@$(objcopy) -S -O binary $< $@


#Generate directories for object, dependency and generated files
.SECONDEXPANSION:

# | is used for squential dependency
# Indicating dir is dependent
$(objs-y) $(deps) $(targets-y): | $$(@D)

# Create directories
$(directories):
	@echo "Creating directory $(patsubst $(cur_dir)/%, %, $@)"
	@mkdir -p $@

# Clean all object
.PHONY: clean
clean:
	@echo "Erasing directories..."
	-rm -rf $(build_dir)
	-rm -rf $(bin_dir)