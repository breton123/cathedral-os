; stage2.asm - second stage bootloader
org 0x1200

jmp START

%include "boot/gdt.asm"

; E820 memory map structures
e820_entry:
	.base_addr_low		dd 0
	.base_addr_high		dd 0
	.length_low		dd 0
	.length_high		dd 0
	.memory_type		dd 0

; Memory map location for kernel access (moved to safer location)
memory_map equ 0x8000	; Place at 0x8000 so kernel can access it

memory_map_data:
	.entry_count		dw 0
	.entries		times 1024 db 0	; Space for up to 64 entries (20 bytes each)

; VESA data structures
vbe_info_block:
	.signature		db "VBE2"	; indicate support for VBE 2.0+
	.version		dw 0
	.oem			dd 0
	.capabilities		dd 0
	.video_modes		dd 0
	.video_memory		dw 0
	.software_rev		dw 0
	.vendor			dd 0
	.product_name		dd 0
	.product_rev		dd 0
	.reserved		times 222 db 0
	.oem_data		times 256 db 0

mode_info_block:
	.attributes		dw 0
	.window_a		db 0
	.window_b		db 0
	.granularity		dw 0
	.window_size		dw 0
	.segment_a		dw 0
	.segment_b		dw 0
	.win_func_ptr		dd 0
	.pitch			dw 0
	.width			dw 0
	.height			dw 0
	.w_char			db 0
	.y_char			db 0
	.planes			db 0
	.bpp			db 0
	.banks			db 0
	.memory_model		db 0
	.bank_size		db 0
	.image_pages		db 0
	.reserved0		db 0
	.red_mask		db 0
	.red_position		db 0
	.green_mask		db 0
	.green_position		db 0
	.blue_mask		db 0
	.blue_position		db 0
	.reserved_mask		db 0
	.reserved_position	db 0
	.direct_color_attributes db 0
	.framebuffer		dd 0
	.off_screen_mem_off	dd 0
	.off_screen_mem_size	dw 0
	.reserved1		times 206 db 0

; Place VESA screen info at a known location for the kernel
vbe_screen equ 0x9000	; Place at 0x9000 so kernel can access it

vbe_screen_data:
	.width			dw 0
	.height			dw 0
	.bpp			db 0
	.bytes_per_pixel	dd 0
	.physical_buffer	dd 0
	.bytes_per_line	dw 0
	.x_cur_max		dw 0
	.y_cur_max		dw 0

START:
    ; Get memory map first
    call GetMemoryMap

    ; Check if we got any memory entries
    cmp word [memory_map_data.entry_count], 0
    je memory_map_fallback

    ; Set default VESA mode parameters (1024x768x32)
    mov ax, 1024
    mov bx, 768
    mov cl, 32
    call SetupVBE

    ; Check if VESA setup was successful
    jc vesa_error

    ; Continue with normal boot process
    call EnableA20
    cli
    lgdt [GDT_DESC]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp codeseg:PM_START

memory_map_fallback:
    ; Create a simple memory map with basic entries
    mov word [memory_map_data.entry_count], 2

    ; Entry 1: 0x00000000 - 0x0009FFFF (640KB conventional memory)
    mov di, memory_map_data.entries
    mov dword [di], 0x00000000      ; base_addr_low
    mov dword [di+4], 0x00000000    ; base_addr_high
    mov dword [di+8], 0x000A0000    ; length_low (640KB)
    mov dword [di+12], 0x00000000   ; length_high
    mov dword [di+16], 0x00000001   ; type (usable)

    ; Entry 2: 0x00100000 - 0x00FFFFFF (15MB extended memory)
    add di, 20
    mov dword [di], 0x00100000      ; base_addr_low
    mov dword [di+4], 0x00000000    ; base_addr_high
    mov dword [di+8], 0x00F00000    ; length_low (15MB)
    mov dword [di+12], 0x00000000   ; length_high
    mov dword [di+16], 0x00000001   ; type (usable)

memory_map_error:
    ; Display memory map error message
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov si, memory_map_error_msg
    mov cx, memory_map_error_len
    rep movsb
    jmp $  ; Halt

vesa_error:
    ; Display error message in text mode
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov si, vesa_error_msg
    mov cx, vesa_error_len
    rep movsb

    ; Also display the mode that failed
    mov di, 80  ; Second line
    mov si, vesa_mode_msg
    mov cx, vesa_mode_len
    rep movsb

    jmp $  ; Halt

memory_map_error_msg: db 'Memory Map Error - No entries found'
memory_map_error_len equ $ - memory_map_error_msg
vesa_error_msg: db 'VESA Error - No suitable mode found'
vesa_error_len equ $ - vesa_error_msg
vesa_mode_msg: db 'Tried modes: 0x118, 0x11A'
vesa_mode_len equ $ - vesa_mode_msg

; GetMemoryMap:
; Gets the system memory map using INT 15h E820
; Stores the map at memory_map_data
; Out\	Entry count stored in memory_map_data.entry_count

GetMemoryMap:
	push es
	push di
	push ebx
	push ecx
	push edx

	mov di, memory_map_data.entries	; Point to where we'll store entries
	mov ebx, 0			; Continuation value, start with 0
	mov word [memory_map_data.entry_count], 0	; Initialize entry count

.loop:
	mov eax, 0xE820		; E820 function
	mov edx, 0x534D4150	; 'SMAP' signature
	mov ecx, 20		; Size of buffer (20 bytes for E820)
	mov di, e820_entry	; Use our local buffer
	int 0x15

	jc .done			; Carry set means error or end

	cmp eax, 0x534D4150	; Check if 'SMAP' returned
	jne .done

	cmp ecx, 20		; Check if we got 20 bytes
	jb .done

	; Copy the entry to the final location
	mov di, memory_map_data.entries
	mov ax, [memory_map_data.entry_count]
	mov bx, 20
	mul bx
	add di, ax

	mov eax, [e820_entry.base_addr_low]
	mov [di], eax
	mov eax, [e820_entry.base_addr_high]
	mov [di+4], eax
	mov eax, [e820_entry.length_low]
	mov [di+8], eax
	mov eax, [e820_entry.length_high]
	mov [di+12], eax
	mov eax, [e820_entry.memory_type]
	mov [di+16], eax

	inc word [memory_map_data.entry_count]

	cmp ebx, 0		; If EBX is 0, we're done
	je .done

	cmp word [memory_map_data.entry_count], 64	; Limit to 64 entries
	jae .done

	jmp .loop

.done:
	pop edx
	pop ecx
	pop ebx
	pop di
	pop es
	ret

EnableA20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; vbe_set_mode:
; Sets a VESA mode
; In\	AX = Width
; In\	BX = Height
; In\	CL = Bits per pixel
; Out\	FLAGS = Carry clear on success
; Out\	Width, height, bpp, physical buffer, all set in vbe_screen structure

SetupVBE:
	mov [.width], ax
	mov [.height], bx
	mov [.bpp], cl

	sti

	push es					; some VESA BIOSes destroy ES, or so I read
	mov ax, 0x4F00				; get VBE BIOS info
	mov di, vbe_info_block
	int 0x10
	pop es

	cmp ax, 0x4F				; BIOS doesn't support VBE?
	jne .error

	mov ax, word[vbe_info_block.video_modes]
	mov [.offset], ax
	mov ax, word[vbe_info_block.video_modes+2]
	mov [.segment], ax

	mov ax, [.segment]
	mov fs, ax
	mov si, [.offset]

.find_mode:
	mov dx, [fs:si]
	add si, 2
	mov [.offset], si
	mov [.mode], dx
	mov ax, 0
	mov fs, ax

	cmp word [.mode], 0xFFFF			; end of list?
	je .error

	push es
	mov ax, 0x4F01				; get VBE mode info
	mov cx, [.mode]
	mov di, mode_info_block
	int 0x10
	pop es

	cmp ax, 0x4F
	jne .error

	mov ax, [.width]
	cmp ax, [mode_info_block.width]
	jne .next_mode

	mov ax, [.height]
	cmp ax, [mode_info_block.height]
	jne .next_mode

	mov al, [.bpp]
	cmp al, [mode_info_block.bpp]
	jne .next_mode

	; If we make it here, we've found the correct mode!
	mov ax, [.width]
	mov word[vbe_screen_data.width], ax
	mov ax, [.height]
	mov word[vbe_screen_data.height], ax

	; Handle 32-bit framebuffer address in 16-bit mode
	mov ax, [mode_info_block.framebuffer]
	mov word[vbe_screen_data.physical_buffer], ax
	mov ax, [mode_info_block.framebuffer+2]
	mov word[vbe_screen_data.physical_buffer+2], ax

	mov ax, [mode_info_block.pitch]
	mov word[vbe_screen_data.bytes_per_line], ax

	mov ax, 0
	mov al, [.bpp]
	mov byte[vbe_screen_data.bpp], al
	shr al, 3
	mov byte[vbe_screen_data.bytes_per_pixel], al
	mov byte[vbe_screen_data.bytes_per_pixel+1], 0
	mov byte[vbe_screen_data.bytes_per_pixel+2], 0
	mov byte[vbe_screen_data.bytes_per_pixel+3], 0

	mov ax, [.width]
	shr ax, 3
	dec ax
	mov word[vbe_screen_data.x_cur_max], ax

	mov ax, [.height]
	shr ax, 4
	dec ax
	mov word[vbe_screen_data.y_cur_max], ax

	; Set the mode
	push es
	mov ax, 0x4F02
	mov bx, [.mode]
	or bx, 0x4000			; enable LFB
	mov di, 0			; not sure if some BIOSes need this... anyway it doesn't hurt
	int 0x10
	pop es

	cmp ax, 0x4F
	jne .error

	clc
	ret

.next_mode:
	mov ax, [.segment]
	mov fs, ax
	mov si, [.offset]
	jmp .find_mode

.error:
	stc
	ret

.width				dw 0
.height				dw 0
.bpp				db 0
.segment			dw 0
.offset				dw 0
.mode				dw 0

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



times 4096-($-$$) db 0