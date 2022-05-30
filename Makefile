SHELL := /bin/bash

PROG_DIR := $(PWD)/code/prog0

.PHONY: all load_prog make_in_build gen_elf

all: | load_prog make_in_build 

load_prog: 
	rm -rf build/*
	ln -sf $(PWD)/Makefile build
	ln -sf $(PROG_DIR) .
	cp $(PROG_DIR)/* build

make_in_build:
	make gen_elf IN_BUILD=1 -C build

ifdef IN_BUILD
  CROSS_PREFIX ?= riscv64-unknown-elf-
  RISCV_GCC    ?= $(CROSS_PREFIX)gcc

  ELF_NAME := main
  LDFILE   := link.ld
  CFLAGS   := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 #-I$(INCDIR)
  LDFLAGS  := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -T$(LDFILE) -lgcc

  SRC_C   := $(wildcard *.c)
  OBJ_C   := $(patsubst %.c,%.o,$(SRC_C))
  SRC_S   := $(wildcard *.S)
  OBJ_S   := $(patsubst %.S,%.o,$(SRC_S))
  BMP     := $(wildcard *.bmp)
  OBJ_BMP := $(patsubst %.bmp,%.o,$(BMP))
  SRC     := $(SRC_C) $(SRC_S)
  OBJ     := $(OBJ_C) $(OBJ_S) $(OBJ_BMP)
endif

gen_elf: $(OBJ) | $(LDFILE)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME)

%.o: %.S
	$(RISCV_GCC) -c $(CFLAGS) $^

%.o: %.c
	$(RISCV_GCC) -c $(CFLAGS) $^
