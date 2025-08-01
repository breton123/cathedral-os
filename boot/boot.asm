; boot.asm - simple two-stage bootloader
org 0x7c00

; Set up stack
mov bp, 0x9000
mov sp, bp

; Save boot drive
mov [boot_drive], dx

; Check if LBA is supported
mov ah, 0x41
mov bx, 0x55aa
mov dx, [boot_drive]
int 0x13
jc error

; Load kernel (sector 1)
mov ah, 0x42
mov dx, [boot_drive]
mov si, kernel_packet
int 0x13
jc error

; Load stage 2 (sectors 2-4)
mov ah, 0x42
mov dx, [boot_drive]
mov si, stage2_packet
int 0x13
jc error

; Jump to stage 2
jmp 0x0000:0x1200

error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

; Variables
boot_drive: dw 0

; Disk packets
kernel_packet:
    db 0x10        ; Packet size
    db 0           ; Reserved
    dw 50          ; Number of sectors (increase from 1 to 10)
    dd 0x1000      ; Transfer buffer
    dq 1           ; Starting LBA (sector 1)

stage2_packet:
    db 0x10        ; Packet size
    db 0           ; Reserved
    dw 8           ; Number of sectors (8 sectors for stage 2 - increased for memory map)
    dd 0x1200      ; Transfer buffer
    dq 2           ; Starting LBA (sector 2)

; Boot signature
times 510 - ($ - $$) db 0
dw 0xaa55
