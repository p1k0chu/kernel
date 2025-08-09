#include <stdint.h>

extern int cursor_x;
extern int cursor_y;

extern uint8_t vga_width;

void putc(char c, char attr);
void putc_white(char);
void printnum(int, char attr);
void print(const char* str, char attr);
void println(const char* str, char attr);

// clears the screen
void clear_vga();

// call once at boot
void print_init();

