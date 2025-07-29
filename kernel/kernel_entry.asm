[BITS 16]

extern kernel_main

global start

start:
    ; Call the C function
    call kernel_main

    ; Print confirmation that C function was called
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov ah, 0x0e
    mov al, 'H'
    int 0x10
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    mov ah, 0x0e
    mov al, 'L'
    int 0x10
    mov ah, 0x0e
    mov al, 'L'
    int 0x10
    mov ah, 0x0e
    mov al, 'O'
    int 0x10
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov ah, 0x0e
    mov al, 'W'
    int 0x10
    mov ah, 0x0e
    mov al, 'O'
    int 0x10
    mov ah, 0x0e
    mov al, 'R'
    int 0x10
    mov ah, 0x0e
    mov al, 'L'
    int 0x10
    mov ah, 0x0e
    mov al, 'D'
    int 0x10

    ; Halt
    jmp $
