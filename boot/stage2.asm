; stage2.asm - second stage bootloader
org 0x1200

; Clear screen
mov ah, 0x00
mov al, 0x03
int 0x10

; Print welcome message
mov si, welcome_msg
call print_string

; Print memory info
mov si, memory_msg
call print_string

; Get and display memory size
mov ah, 0x88
int 0x15
mov bx, ax
call print_hex

; Print newline
mov si, newline
call print_string

; Print loading message
mov si, loading_msg
call print_string

; Jump to kernel (loaded at 0x1000)
jmp 0x0000:0x1000

; Print string function
print_string:
    lodsb
    test al, al
    jz print_done
    mov ah, 0x0e
    int 0x10
    jmp print_string
print_done:
    ret

; Print hex number in BX
print_hex:
    mov cx, 4
print_hex_loop:
    rol bx, 4
    mov al, bl
    and al, 0x0f
    add al, '0'
    cmp al, '9'
    jbe print_hex_digit
    add al, 7
print_hex_digit:
    mov ah, 0x0e
    int 0x10
    loop print_hex_loop
    ret

; Messages
welcome_msg: db 'Cathedral OS Bootloader Stage 2', 13, 10, 0
memory_msg: db 'Memory size: ', 0
loading_msg: db 'Loading kernel...', 13, 10, 0
newline: db 13, 10, 0

; Pad to fill 3 sectors (1536 bytes)
times 1536 - ($ - $$) db 0