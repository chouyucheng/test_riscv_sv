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
	if   [ "$(PROG)" != "" ]; then make gen_elf MF=prog -f $(TOPDIR)/Makefile; \
	elif [ "$(ASM)"  != "" ]; then make gen_elf MF=asm  -f $(TOPDIR)/Makefile; \
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
CROSS_PREFIX ?= riscv64-unknown-elf-
RISCV_GCC    ?= $(CROSS_PREFIX)gcc

ELF_NAME := main
CFLAGS   := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 #-I$(INCDIR)
LDFLAGS  := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -T$(LDFILE) -lgcc

.PHONY: gen_elf

gen_elf: $(OBJ) | $(LDFILE)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME)

%.o: $(DIR)/%.c
	$(RISCV_GCC) -c $(CFLAGS) $^

%.o: $(DIR)/%.S
	$(RISCV_GCC) -c $(CFLAGS) $^

endif

