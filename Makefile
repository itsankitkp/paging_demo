OBJECTS = loader.o 
LDFLAGS = -T link.ld -melf_i386
AS = nasm
ASFLAGS = -g -F dwarf -f elf 

QEMU = qemu-system-i386

ASM_SRCS := $(shell find . -name "*.s") 
# Object files
OBJS := $(ASM_SRCS:%.s=%.o)

all: kernel.elf
kernel.elf: $(OBJS)
	ld $(LDFLAGS) $(OBJS) -o kernel.elf

os.iso: kernel.elf
	mkdir -p iso
	mkdir -p iso/boot
	mkdir -p iso/boot/grub
	mkdir -p iso/boot/modules
	cp kernel.elf iso/boot/kernel.elf
	cp grub.cfg iso/boot/grub/grub.cfg
	grub-mkrescue -o os.iso iso/

run: os.iso
	$(QEMU) -boot d -cdrom os.iso -m 512 -monitor stdio

debug: os.iso
	$(QEMU) -boot d -cdrom os.iso -m 512 -s -S

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm $(OBJS) $(TARGET)
	rm kernel.elf
	rm os.iso
	rm -rf iso 
	 
	


