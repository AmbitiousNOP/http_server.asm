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
	; get a socket file descriptor
	mov rax, 41	; syscall socket()
	mov rdi, 2	; AF_INET
	mov rsi, 1	; TCP	
	mov rdx, 0	; defaults to 0 but just incase rdx isnt inti'd to 0
	syscall 
	cmp rax, 0			; check for error returned by socket syscall
	jl close_server			; if < 0 close_server due to error.
	mov [server_socket], rax	; move the file descriptor to server_socket

	; convert port to nework byte order
	;NOTE: bind() freaks out when i pass in manually.
	;TODO: manually pass it and take out htons 
	mov rdi, [port]
	call htons
	mov [server_addr+sockaddr_in.sin_port], rax	; move returned value into struct 
	; FIX: add error handling.

	; convert ip_address to network byte order
	;NOTE: bind() again freaks out when i pass in manually.
	;TODO: manually pass it and take out inet_aton.
	mov rdi, ip_address
	mov rsi, server_addr + sockaddr_in.sin_addr
	call inet_aton
	;FIX: add error handling. 

	; setting the socket options to re-use address
	mov rax, 54			; syscall setsockopt()
	mov rdi, [server_socket]	; file descriptor
	mov rsi, 1			; SOL_SOCKET
	mov rdx, 2			; SO_REUSEADDR
	mov r10, 1			; reuseaddr_enabled
	mov r8, 4
	syscall 
	cmp rax, 0			; check for error 
	jge close_server		; if error close server

	; assign address to socket 	
	mov rax, 49			; syscall bind()
	mov rdi, [server_socket]	; file descriptor
	mov rsi, server_addr		; pointer to struct 
	mov rdx, 16			; length of struct
	syscall 
	cmp rax, 0			; error checking
	jne close_server		; if not 0 close server
	
	;TODO: listen() for connecting clients
	;TODO: accept() incoming connection
	;TODO: recv() data from the client
	;TODO: send() resp to client
	;TODO: close() client_fd connection


	; close fd
	mov rax, 3			; syscall for close()
	mov rdi, [server_socket]	; file descriptor to close
	syscall

	; exit program
	mov rax, 60			; syscall for exit()
	xor rdi, rdi			; return 0 for success
	syscall	


close_server:
	; close fd
	mov rax, 3			; syscall for close()
	mov rdi, [server_socket]	; fiel descriptor to close
	syscall 

	; exit program 
	mov rax, 60			; syscall for exit()
	xor rdi, 1			; exit with error (1) 
	syscall


