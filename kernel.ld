ENTRY(_start)

SECTIONS {
  . = 0x100000;

  .text : {
      KEEP(*(.start))
      *(.text)
  }

  .data : {
    *(.data)
  }

  .bss : {
    *(.bss)
  }
}
