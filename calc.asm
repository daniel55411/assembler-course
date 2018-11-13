.data
    operand_1 = 10
    operand_2 = 2
    operation = '/'
    error_message:
        .asciz "Not known operation\n"
    l_error_message = . - error_message
    line_feed: .byte 0x0A
    minus: .byte 0x2D
    
.text
    .global _start
    
_start:
    movq $operation, %rcx
    cmpq $0x2B, %rcx
    je _sum
    cmpq $0x2A, %rcx
    je _mul
    cmpq $0x2D, %rcx
    je _sub
    cmpq $0x2F, %rcx
    je _div
    jmp _error

_error:
    mov $error_message, %rsi
    mov $l_error_message, %rdx
    call _console_write
    jmp _exit_error

_console_write:
    movq $1, %rax
    movq $1, %rdi
    syscall
    ret
 
_pre_process:
    cmpq $0, %rax
    jge _process
    neg %eax
    push %rax
    movq $minus, %rsi
    movq $1, %rdx
    call _console_write
    pop %rax
    jmp _process

_process:
    xorq %r10, %r10
_process_step:
    movq $0, %rdx
    movq $10, %rbx
    divq %rbx
    addq $48, %rdx
    push %rdx
    incq %r10
    cmpq $0, %rax
    jz _print       
    jmp _process_step

 _print:
    cmpq $0, %r10
    jz _exit_success
    decq %r10
    mov %rsp, %rsi
    movq $1, %rdx
    call _console_write
    add $8, %rsp
    jmp _print

_exit_error:
    movq $1, %rdi
    jmp _exit

_exit_success:
    movq $line_feed, %rsi
    movq $1, %rdx
    call _console_write
    movq $0, %rdi
    jmp _exit

_exit:
    movq $60, %rax
    syscall

_sum:
    movq $operand_1, %rax
    addq $operand_2, %rax
    jmp _pre_process

_sub:
    movq $operand_1, %rax
    subq $operand_2, %rax
    jmp _pre_process
    
_mul:
    xorq %rax, %rax
    movq $operand_2, %rcx
    mov $operand_1, %al
    mul %rcx
    jmp _pre_process

_div:
    xorq %rax, %rax
    movq $operand_2, %rcx
    movq $0, %rdx
    movq $operand_1, %rax
    div %rcx
    jmp _pre_process
