main: main.o
	ld -o main main.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L. -lraylib -lc -lm -lX11
main.o: main.asm
	fasm main.asm
