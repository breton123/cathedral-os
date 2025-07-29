// Simple BIOS print function
void print_char(char c) {
    __asm__ volatile (
        "mov $0x0e, %%ah\n"
        "mov %0, %%al\n"
        "int $0x10\n"
        :
        : "r" (c)
        : "ah", "al"
    );
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str);
        str++;
    }
}

void kernel_main(void) {
    // Simple test - just return and let assembly handle output
    return;
}
