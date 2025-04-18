.section .data
    input_prompt: .asciz "Please enter some text to be displayed to the terminal (limit 20 chars):\n"
    input_prompt_len = . - input_prompt

    null_err: .asciz "Error: Input can not be null\n"
    null_err_len = . - null_err

    newline_err: .asciz "Error: You did not enter any text!\n"
    newline_err_len = . - newline_err

    overflow_err: .asciz "Error: You entered more than 20 characters!\n"
    overflow_err_len = . - overflow_err

.section .bss
    in_buf: .skip 21
    in_buf_len = . - in_buf

    overflow_buf: .skip 1
    overflow_buf_len = . - overflow_buf

.section .text
.globl _start

_start:
    call prompt_input
    lea in_buf(%rip), %rsi
    mov $in_buf_len, %rdx
    call syscall_read
    call input_validation
    lea in_buf(%rip), %rsi
    mov %rax, %rdx
    call syscall_write
    jmp exit_program

syscall_read:
    # read(fd, *buf, count) syscall 0
    # rdi, rsi, rdx
    # returns read data length in bytes in rax
    # expects: rsi and rdx already set
    mov $0, %rax
    mov $0, %rdi
    syscall
    ret

syscall_write:
    # write(fd, *buf, count) syscall 1
    # rdi, rsi, rdx
    # expects: rsi and rdx already set
    mov $1, %rax
    mov $1, %rdi
    syscall
    ret

prompt_input:
    lea input_prompt(%rip), %rsi
    mov $input_prompt_len, %rdx
    call syscall_write
    ret

input_validation:
    call check_null
    call check_newline
    call check_overflow
    ret

check_null:
    test %rax, %rax
    jz handle_null
    ret

handle_null:
    lea null_err(%rip), %rsi
    mov $null_err_len, %rdx
    call syscall_write
    jmp exit_program

check_newline:
    # 0x10 = \n
    cmpb $10, in_buf(%rip)
    je handle_newline
    ret

handle_newline:
    lea newline_err(%rip), %rsi
    mov $newline_err_len, %rdx
    call syscall_write
    jmp exit_program

check_overflow:
    cmp $20, %rax
    jg check_final_byte
    ret

check_final_byte:
    mov $in_buf_len, %r8
    sub $1, %r8
    lea in_buf(%rip), %rsi
    add %r8, %rsi
    movzbq (%rsi), %r9
    cmpb $10, %r9b
    jne handle_overflow
    ret

handle_overflow:
    lea overflow_err(%rip), %rsi
    mov $overflow_err_len, %rdx
    call syscall_write
    call flush_stdin
    jmp exit_program

flush_stdin:
    lea overflow_buf(%rip), %rsi
    mov $overflow_buf_len, %rdx
    call syscall_read
    cmpb $10, overflow_buf(%rip)
    je flush_done
    test %rax, %rax
    jz flush_done
    cmp $overflow_buf_len, %rax
    je flush_stdin

flush_done:
    ret

exit_program:
    mov $60, %rax
    mov $0, %rdi
    syscall

