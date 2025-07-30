; stage2.asm - second stage bootloader
org 0x1200

jmp START

%include "boot/gdt.asm"

START:
    call EnableA20
    cli
    lgdt [GDT_DESC]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp codeseg:PM_START

EnableA20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

[BITS 32]

PM_START:
    mov ax, dataseg
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; Set up stack
    mov esp, 0x90000

    ; Clear the screen
    mov edi, 0xb8000
    mov ecx, 2000  ; 80x25 characters
    mov ax, 0x0f20  ; white on black space
    rep stosw

    ; Check if kernel signature is at 0x1000
    mov eax, [0x1000]
    cmp eax, 0x00000000  ; Check if it's all zeros
    je kernel_empty
    jmp kernel_loaded

kernel_empty:
    mov [0xb800e], byte 'E'
    mov [0xb800f], byte 0x0f

kernel_loaded:
    ; Jump to kernel at 0x1000 (already loaded by bootloader)
    jmp 0x1000

times 2048-($-$$) db 0

