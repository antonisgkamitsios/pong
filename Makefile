game: game.o
	ld -o game game.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L. -lraylib -lc -lm -lX11
game.o: game.asm
	fasm game.asm 

test: test.c 
	cc -o test test.c -L. -lraylib -lc -lm -lX11
	objdump -d -M intel --disassemble=main test