.equ SYS_WRITE, 1
.equ SYS_OPEN, 2
.equ SYS_CLOSE, 3
.equ SYS_SOCKET, 41
.equ SYS_CONNECT, 42
.equ SYS_ACCEPT, 43
.equ SYS_RECVFROM, 45
.equ SYS_BIND, 49
.equ SYS_LISTEN, 50
.equ AF_INET, 2
.equ SOCK_STREAM, 1
.equ PORT, 8080
.equ IPADDR, 0x00000000

.section .data
    sockaddr:
        # __SOCK_SIZE__ 16 bytes,   sizeof(struct sockaddr)
        # sa_family_t   sin_family  address family
        # in_port_t     sin_port    port in network byte order
        # in_addr       sin_addr    internet address
        .word AF_INET   # 2 bytes,  unsigned short (sa_family_t)
        .word PORT      # 2 bytes,  uint16_t (in_port_t)
        .long IPADDR    # 4 bytes,  uint32_t (in_addr)
        .zero 8         # 8 bytes   padding

    read_buf: .skip 64
    read_buf_len = . - read_buf

    client_socketaddr: .zero 16
    client_addrlen: .quad 16

.section .text
.globl _start

_start:
    call create_socket
    jmp byte_swap_port

create_socket:
    # socket(domain, type, protocol)
    # rdi, rsi, rdx
    mov $AF_INET, %rdi
    mov $SOCK_STREAM, %rsi
    # let kernel use default protocol
    # explicit protocol numbers in /etc/protocol
    mov $0, %rdx
    mov $SYS_SOCKET, %rax
    syscall
    mov %rax, %r12                          # r12: listening socketfd
    ret

byte_swap_port:
    # swap to network byte order
    mov $0, %rax
    movw sockaddr+2(%rip), %ax
    rol $8, %ax
    movw %ax, sockaddr+2(%rip)
    jmp bind_port

bind_port:
    # bind(sockfd, *addr, addrlen)
    # rdi, rsi, rdx
    mov %r12, %rdi
    lea sockaddr(%rip), %rsi
    mov $16, %rdx
    mov $SYS_BIND, %rax
    syscall
    jmp listen

listen:
    # listen(sockfd, backlog)
    # rdi, rsi
    mov $10, %rsi
    mov $SYS_LISTEN, %rax
    syscall
    jmp handle_client

handle_client:
    call accept
    call recv
    call write
    call close
    jmp handle_client

accept:
    # accept(sockfd, *addr, *addrlen)
    # rdi, rsi, rdx
    mov %r12, %rdi
    lea client_socketaddr(%rip), %rsi
    lea client_addrlen(%rip), %rdx
    mov $SYS_ACCEPT, %rax
    syscall
    mov %rax, %r13                          # r13: client socketfd
    ret

recv:
    # recv(sockfd, *buf, len, flags)
    # rdi, rsi, rdx, r10
    mov %r13, %rdi
    lea read_buf(%rip), %rsi
    mov $read_buf_len, %rdx
    mov $SYS_RECVFROM, %rax
    syscall
    mov %rax, %r14                          # r14: bytes read in
    ret

write:
    # write(fd, *buf, count)
    # rdi, rsi, rdx
    mov $1, %rdi
    lea read_buf(%rip), %rsi
    mov %r14, %rdx
    mov $SYS_WRITE, %rax
    syscall
    ret

close:
    # close(fd)
    # rdi
    mov %r13, %rdi
    mov $SYS_CLOSE, %rax
    syscall
    ret

