section .data
	socket_desc dq 0	; store the socket descriptor
	addr db 2, 0		; store the address returned by getsockname
	port dw 0x560F	; port 8080 in big-endian
	ip_addr dd 0x0100007F	; ip addr 0.0.0.0
	padding db 8 dup(0)
	addr_len dw 32		; lenght of the address

section .text
global _start

_start:
	; call socket() 
	mov rax, 0x29	; scoket() syscall
	mov rdi, 2	; AF_INET
	mov rsi, 1	; SOCK_STREAM
	mov rdx, 6	; assuming a single protocol exist for sock_stream
	syscall
	mov [socket_desc], rax	; store socket fd
	cmp rax, 0 
	jl close_server


	; bind() to  a random port so getsockname can return an addr
	mov rax, 0x31			; bind() syscall
	mov rdi, [socket_desc]		;sockfd
	mov rsi, addr			; address of socket addr struct
	mov rdx, dword 32	; point to addr 
	syscall
	cmp rax, 0 
	jne close_server

	; listen on port for connection
	mov rax, 0x32		; listen() syscall
	mov rdi, [socket_desc]	; file descriptor
	mov rsi, 5		; max clients
	syscall
	cmp rax, 0		; check for error in rax
	jne close_server

	; close fd
	mov rax, 0x03
	mov rdi, [socket_desc]
	syscall
	; exit program
	mov rax, 0x3c
	xor rdi, rdi
	syscall	


	; ------ TODO: implement uname somwhere


close_server:
	; close fd
	mov rax, 0x03
	mov rdi, [socket_desc]
	syscall 

	; exit program 
	mov rax, 0x3c
	xor rdi, 1	; exit with error (1) 
	syscall
