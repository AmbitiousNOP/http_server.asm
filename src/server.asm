%include "c.inc"

SECTION .data
ip_address: db "0.0.0.0", 0

server_addr:
	istruc sockaddr_in
	at sockaddr_in.sin_family, dw 2
	at sockaddr_in.sin_port, dw 0
	at sockaddr_in.sin_addr, dd 0
	at sockaddr_in.sin_zero, dq 0
	iend

SECTION .bss
port: resq 1
server_socket resq 1

SECTION .text
	global main

main: 
	; syscall socket()
	mov rax, 41
	mov rdi, 2
	mov rsi, 1
	mov rdx, 0
	syscall 
	mov [server_socket], rax 
	cmp rax, 0
	jl close_server
	
	; htons for port
	mov rdi, [port]
	call htons
	mov [server_addr+sockaddr_in.sin_port], rax 
	
	; inet_aton for ip_addr
	mov rdi, ip_address
	mov rsi, server_addr + sockaddr_in.sin_addr
	call inet_aton


	mov rax, 54
	mov rdi, [server_socket]
	mov rsi, 1	; SOL_SOCKET
	mov rdx, 2	; SO_REUSEADDR
	mov r10, 1	; reuseaddr_enabled
	mov r8, 4
	syscall 
	cmp rax, 0
	jge close_server

	; syscall bind()
	mov rax, 49
	mov rdi, [server_socket]
	mov rsi, server_addr
	mov rdx, 16
	syscall 
	cmp rax, 0
	jne close_server

	; close fd
	mov rax, 0x03
	mov rdi, [server_socket]
	syscall
	; exit program
	mov rax, 0x3c
	xor rdi, rdi
	syscall	


close_server:
	; close fd
	mov rax, 0x03
	mov rdi, [server_socket]
	syscall 

	; exit program 
	mov rax, 0x3c
	xor rdi, 1	; exit with error (1) 
	syscall

	


