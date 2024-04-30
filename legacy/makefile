build:
	nasm -f elf64 -g server.asm
	ld server.o -o server

run:
	./server

clean:
	rm -rf *.o server
