ENTRY(start)

SECTIONS {
  . = 0x8000;

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
