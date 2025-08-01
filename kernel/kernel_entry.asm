[BITS 32]

extern kernel_main
extern __bss_start
extern __bss_end

global start

; Add distinctive signature at the very beginning
start:
    ; Set up segment registers
    mov ax, 0x10    ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up stack with more space
    mov esp, 0x90000  ; Stack at 0x90000
    mov ebp, esp      ; Set up frame pointer

    ; Clear interrupts
    cli

    ; Initialize .bss section (zero-initialized global variables)
    mov edi, __bss_start
    mov ecx, __bss_end
    sub ecx, edi
    cmp ecx, 0        ; Check if .bss size is valid
    jle skip_bss      ; Skip if size is 0 or negative
    xor eax, eax
    rep stosb
skip_bss:

    ; Clear some registers
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    ; Call the main kernel function
    call kernel_main

    ; Halt the system - prevent jumping back to stage2
    cli
    hlt
