.section .data
    msg: .ascii "hello world :D\n"
    msg_len = . - msg

.section .text
.globl _start

_start:
    # write(fd, *buf, count)
    # fd: 0 = stdout, 1 = stdin, 2 = stderr
    # x86-64 system call args:
    # rdi, rsi, rdx, r10, r8, r9
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov $msg_len, %rdx
    syscall

    mov $60, %rax
    xor %rdi, %rdi
    syscall
