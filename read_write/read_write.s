.section .data

.section .bss
    in_buf: .skip 32
    in_buf_len = . - in_buf
    read_bytes: .skip 8

.section .text
.globl _start

_start:
    # read(fd, *buf, count) syscall 0
    # rdi, rsi, rdx
    mov $0, %rax
    mov $0, %rdi
    lea in_buf(%rip), %rsi
    mov $in_buf_len, %rdx
    syscall

    # returns num of bytes read
    mov %rax, read_bytes(%rip)

    # write
    mov $1, %rax
    mov $1, %rdi
    # rsi shouldn't have changed?
    mov read_bytes(%rip), %rdx
    syscall

    # exit
    mov $60, %rax
    mov $0, %rdi
    syscall

