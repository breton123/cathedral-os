; boot.asm - bootloader with LBA disk read
org 0x7c00

; Set up stack
mov bp, 0x9000
mov sp, bp

; Save boot drive
push dx

; Check if LBA is supported
mov ah, 0x41
mov bx, 0x55aa
pop dx
push dx
int 0x13
jc error

; Use LBA read
mov ah, 0x42
pop dx
push dx
mov si, disk_packet
int 0x13
jc error

; Check if we got data
mov ax, 0x0000
mov es, ax
mov al, [es:0x1000]
test al, al
jz error

jmp 0x0000:0x1000

error:
    ; Show error code
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    mov al, ah
    add al, '0'
    int 0x10
    jmp $

; Disk packet for LBA
disk_packet:
    db 0x10        ; Packet size
    db 0           ; Reserved
    dw 2           ; Number of sectors (increased from 1 to 2)
    dd 0x1000      ; Transfer buffer
    dq 1           ; Starting LBA (sector 1)

; Boot signature
times 510 - ($ - $$) db 0
dw 0xaa55
