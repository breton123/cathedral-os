# Targets
all: os.img

# Assemble the bootloader
boot/boot.bin: boot/boot.asm
	nasm -f bin boot/boot.asm -o boot/boot.bin

# Assemble the kernel (flat binary)
kernel.bin: kernel/kernel_entry.asm
	nasm -f bin kernel/kernel_entry.asm -o kernel.bin

# Create floppy disk image with bootloader and kernel
os.img: boot/boot.bin kernel.bin
	dd if=/dev/zero of=os.img bs=512 count=2880
	dd if=boot/boot.bin of=os.img conv=notrunc
	dd if=kernel.bin of=os.img conv=notrunc seek=1

# Run the image in QEMU
run:
	qemu-system-i386 -hda os.img

# Clean build artifacts
clean:
	rm -f *.bin *.o *.elf os.img
