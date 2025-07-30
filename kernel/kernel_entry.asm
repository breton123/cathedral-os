[BITS 32]

extern kernel_main

global start

; Add distinctive signature at the very beginning
start:
    call kernel_main;

    ; Halt the system - prevent jumping back to stage2
    cli
    hlt
