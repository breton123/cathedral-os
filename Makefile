# Targets
all: os.img

# Assemble the bootloader
boot/boot.bin: boot/boot.asm
	nasm -f bin boot/boot.asm -o boot/boot.bin

# Assemble stage 2 bootloader
boot/stage2.bin: boot/stage2.asm
	nasm -f bin boot/stage2.asm -o boot/stage2.bin

# Assemble the kernel (flat binary)
kernel/kernel_entry.o: kernel/kernel_entry.asm
	nasm -f elf kernel/kernel_entry.asm -o kernel/kernel_entry.o

kernel/kernel.o: kernel/kernel.c
	gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -march=i386 -fno-builtin -nostdlib -nostartfiles -nodefaultlibs -fno-common -fno-asynchronous-unwind-tables -c kernel/kernel.c -o kernel/kernel.o

kernel.bin: kernel/kernel_entry.o kernel/kernel.o
	ld -m elf_i386 -T kernel.ld -o kernel.elf $^
	objcopy -O binary kernel.elf kernel.bin

# Create floppy disk image with bootloader, stage2, and kernel
os.img: boot/boot.bin boot/stage2.bin kernel.bin
	dd if=/dev/zero of=os.img bs=512 count=2880
	dd if=boot/boot.bin of=os.img conv=notrunc
	dd if=kernel.bin of=os.img conv=notrunc seek=1
	dd if=boot/stage2.bin of=os.img conv=notrunc seek=2

# Run the image in QEMU
run:
	qemu-system-i386 -hda os.img -no-acpi -no-reboot -no-shutdown -d cpu_reset

# Clean build artifacts
clean:
	rm -f *.bin *.o *.elf os.img
