#!/bin/bash

#PROG="prog0"
PROG="rv32ui-p-add"

if [[ "$PROG" =~ prog ]]; then
  cp code/${PROG}/* build/
  cd build
  make all -f ../code/Makefile

  cd -
  cp build/*.hex sim/
else
  cp code/isa_rv32ui-p/${PROG}* build/
  cd build
  make build_hex ELF_NAME=${PROG} -f ../code/Makefile

  cd -
  cp build/*.hex sim/
  cp code/jump_asm/*.hex sim/
fi


