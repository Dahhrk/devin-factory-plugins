AS = nasm
ASFLAGS = -f elf64
LD = ld

ok: ok.o
	$(LD) ok.o -o ok

ok.o: ok.asm
	$(AS) $(ASFLAGS) ok.asm -o ok.o
