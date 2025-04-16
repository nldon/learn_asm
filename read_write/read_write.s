.section .data
    empty_err: .asciz "Error: Input can not be empty\n"
    empty_err_len = . - empty_err

.section .bss
    in_buf: .skip 32
    in_buf_len = . - in_buf

.section .text
.globl _start

_start:
    call read_input
    call write_stdout
    jmp exit_program

read_input:
    # read(fd, *buf, count) syscall 0
    # rdi, rsi, rdx
    mov $0, %rax
    mov $0, %rdi
    lea in_buf(%rip), %rsi
    mov $in_buf_len, %rdx
    syscall
    call input_validation
    ret

input_validation:
    test %rax, %rax
    jz handle_empty
    # 0x10 = \n
    cmpb $10, in_buf(%rip)
    je handle_empty
    ret

handle_empty:
    mov $1, %rax
    mov $1, %rdi
    lea empty_err(%rip), %rsi
    mov $empty_err_len, %rdx
    syscall
    jmp exit_program

write_stdout:
    # write(fd, *buf, count) syscall 1
    # rdi, rsi, rdx
    mov %rax, %rdx
    mov $1, %rax
    mov $1, %rdi
    syscall
    ret

exit_program:
    mov $60, %rax
    mov $0, %rdi
    syscall

