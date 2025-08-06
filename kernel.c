#include "kernel_asm.h"
#include "print.h"
#include "vga_color.h"

void kernel_main() {
    print_init();

    clear_vga();

    println(
        "RAHHHHHH\n"
        "WHAT THE FUCK IS AN\n"
        "OS?????",
        WHITE | BLUE_BG);

    print("The screen width is: ", WHITE);
    printnum(vga_width);
    println("", 0);
    printnum(-1);
    println("", 0);
    printnum(-69);
    println("", 0);
    printnum(69);
}

