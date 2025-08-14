ENTRY(_start)

SECTIONS {
  . = 0x8000;

  .text : {
    KEEP(*(.start))
    *(.text)
  }

  .data : {
    *(.data)
  }

  .rodata : {
    *(.rodata*)
  }

  .bss : {
    *(.bss)
  }
}
