SHELL := /bin/bash

ifndef MF
export TOPDIR := $(PWD)
export PROG   := $(PROG)
export ASM    := $(ASM)

.PHONY: help build clean

help:
	@echo "serval is the best!!!"

build:
	@ \
	cd build; \
	if   [ "$(PROG)" != "" ]; then make gen_hex MF=prog -f $(TOPDIR)/Makefile; \
	elif [ "$(ASM)"  != "" ]; then make         MF=asm  -f $(TOPDIR)/Makefile; \
	fi

clean:
	rm -rf $(TOPDIR)/build/*

endif

ifeq ($(MF), prog)
DIR    := $(TOPDIR)/code/prog$(PROG)
CSRC   := $(wildcard $(DIR)/*.c)
SSRC   := $(wildcard $(DIR)/*.S)
OBJ     = $(notdir $(patsubst %c, %o, $(CSRC)))
OBJ    += $(notdir $(patsubst %S, %o, $(SSRC)))
LDFILE := $(DIR)/link.ld
endif
	
ifeq ($(MF), asm)
endif

ifdef MF
CROSS_PREFIX  ?= riscv64-unknown-elf-
RISCV_GCC     ?= $(CROSS_PREFIX)gcc
RISCV_OBJCOPY ?= $(CROSS_PREFIX)objcopy -O verilog
RISCV_OBJDUMP ?= $(CROSS_PREFIX)objdump -xsd

ELF_NAME := main
CFLAGS   := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 #-I$(INCDIR)
LDFLAGS  := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -T$(LDFILE) -lgcc

.PHONY: help gen_hex gen_log

help:
	@echo "MF = $(MF), serval is the best!!!"

gen_hex: $(ELF_NAME)
	$(RISCV_OBJCOPY) $< -i 4 -b 0 sram_0_0.hex
	$(RISCV_OBJCOPY) $< -i 4 -b 1 sram_0_1.hex
	$(RISCV_OBJCOPY) $< -i 4 -b 2 sram_0_2.hex
	$(RISCV_OBJCOPY) $< -i 4 -b 3 sram_0_3.hex

gen_log: $(ELF_NAME)
	$(RISCV_OBJDUMP) $< > $(ELF_NAME).log

#DRAM_START="0x80000000"
#${RISCV_OBJCOPY} $1 -i 4 -b 0 --change-addresses -${DRAM_START} ddr_0.hex

ifeq ($(MF), prog)
$(ELF_NAME): $(OBJ) | $(LDFILE)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME)

%.o: $(DIR)/%.c
	$(RISCV_GCC) -c $(CFLAGS) $^

%.o: $(DIR)/%.S
	$(RISCV_GCC) -c $(CFLAGS) $^
endif #ifeq ($(MF), prog)
endif #ifedf MF

