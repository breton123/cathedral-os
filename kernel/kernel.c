
void kernel_main(void) __attribute__((cdecl));


// Simple print string function for VGA text mode
void print_string(const char* str) {
    volatile unsigned char* vga = (volatile unsigned char*)0xb8000;
    static int cursor_x = 0;
    static int cursor_y = 0;

    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] == '\n') {
            cursor_x = 0;
            cursor_y++;
            if (cursor_y >= 25) {
                cursor_y = 0; // Simple wrap around
            }
            continue;
        }

        int offset = (cursor_y * 80 + cursor_x) * 2;
        vga[offset] = str[i];
        vga[offset + 1] = 0x0f; // White on black

        cursor_x++;
        if (cursor_x >= 80) {
            cursor_x = 0;
            cursor_y++;
            if (cursor_y >= 25) {
                cursor_y = 0; // Simple wrap around
            }
        }
    }
}

void kernel_main(void) {
    print_string("Hello from Cathedral OS!\n");
    print_string("Press any key to continue...\n");

}
