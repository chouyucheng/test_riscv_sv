SECTIONS {
  . = 0x0;
  .text : {
    jump.o(.text);
  }
}
