section .bss
	addr resb 16	; allocate 16 bytes for struct sockaddr_in

section .data
	socket_desc dq 0	; store the file descriptor returned by socket()
	;sin_family dd 2		; represents AF_INET for socket() and bind()
	;sin_port dw 0x1F90	; port 8080
	;sin_addr dd 0x7F000001	; 127.0.0.1 stored in netowrk byte order

section .text
	global _start

_start: 
	; call socket()
	mov rax, 0x29
	mov rdi, 2	; AF_INET
	mov rsi, 1	; SOCK_STREAM
	mov rdx, 6	; TCP
	syscall 
	cmp rax, 0	; check if -1 returned for error
	jl close_server	; jumping on error
	mov [socket_desc], rax	; store socket fd

	; initalize sockaddr_in fields
	mov dword [addr], 2	; 4 bytes
	mov word [addr + 2], 0x560F	; 16 bytes
	mov dword [addr + 4], 0x7F000001	;
	mov qword [addr + 8], 0

	; call bind()
	mov rax, 0x31		;bind syscall
	mov rdi, [socket_desc]	; socket fd 
	mov rsi, addr		; address of socket addr
	mov rdx, 16
	syscall
	cmp rax, 0
	jne close_server


close_server:
	; close fd
	mov rax, 0x03
	mov rdi, [socket_desc]
	syscall 

	; exit program 
	mov rax, 0x3c
	xor rdi, 1	; exit with error (1) 
	syscall


