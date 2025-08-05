
#define WHITE_FG 0b00001111

extern volatile short *const vga_mem;
extern char                  vga_width;

void print(int x, int y, const char *str, char attr);
void clear_vga();

