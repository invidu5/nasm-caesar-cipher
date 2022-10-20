Usage:

nasm -f elf caesar.asm
ld -m elf_i386 caesar.o -o caesar.elf
./caesar.elf [string to encode]
