.section .data
    empty_err: .asciz "Error: Input can not be empty\n"
    empty_err_len = . - empty_err

.section .bss
    in_buf: .skip 32
    in_buf_len = . - in_buf

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
    # test for empty input (null), not possible from keyboard as enter
    # submits a newline at least. Doable with cat /dev/null
    test %rax, %rax
    jz handle_empty
    # test for just the newline char, submit with no characters written
    cmpb $10, in_buf(%rip)
    je handle_empty

    # write(fd, *buf, count) syscall 1
    # rdi, rsi, rdx
    # can push the value in rax straight into rdx here rather than use an
    # intermediate label to save an instruction.
    # also don't have to set rsi again, it's still pointing to the buffer
    # mem address
    mov %rax, %rdx
    mov $1, %rax
    mov $1, %rdi
    syscall
    jmp exit_program

exit_program:
    mov $60, %rax
    mov $0, %rdi
    syscall

handle_empty:
    mov $1, %rax
    mov $1, %rdi
    lea empty_err(%rip), %rsi
    mov $empty_err_len, %rdx
    syscall
    jmp exit_program
