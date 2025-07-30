GDT_NULL_DESC:
     dd 0
     dd 0
GDT_CODE_DESC:
     dw 0xffff
     dw 0x0000
     db 0x00
     db 10011010b
     db 11001111b
     db 0x00
GDT_DATA_DESC:
     dw 0xffff
     dw 0x0000
     db 0x00
     db 10010010b
     db 11001111b
     db 0x00

GDT_END:
     GDT_DESC:
          GDT_SIZE:
               dw GDT_END - GDT_NULL_DESC - 1
               dd GDT_NULL_DESC

codeseg equ GDT_CODE_DESC - GDT_NULL_DESC
dataseg equ GDT_DATA_DESC - GDT_NULL_DESC
