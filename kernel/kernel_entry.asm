[BITS 16]

; Kernel that uses BIOS to print text
mov ah, 0x0e
mov al, 'H'
int 0x10
mov al, 'E'
int 0x10
mov al, 'L'
int 0x10
mov al, 'L'
int 0x10
mov al, 'O'
int 0x10
mov al, ' '
int 0x10
mov al, 'W'
int 0x10
mov al, 'O'
int 0x10
mov al, 'R'
int 0x10
mov al, 'L'
int 0x10
mov al, 'D'
int 0x10

jmp $
