.data
    operand_1 = 10
    operand_2 = 2
    operation = '/'
    message: 
        .asciz "Result: %d\n"
    
.extern printf
.text
    .global main
    
main:
    movq %rsp, %rbp
    subq $32, %rsp
    
    movq $operation, %rcx
    cmpq $0x2B, %rcx
    je _sum
    cmpq $0x2A, %rcx
    je _mul
    cmpq $0x2D, %rcx
    je _sub
    cmpq $0x2F, %rcx
    je _div
 
 _print:
    movq $message, %rcx
    movq %rax, %rdx
    call printf
    
    movq %rbp, %rsp
    ret

_sum:
    movq $operand_1, %rax
    addq $operand_2, %rax
    jmp _print

_sub:
    movq $operand_1, %rax
    subq $operand_2, %rax
    jmp _print
    
_mul:
    xorq %rax, %rax
    movq $operand_2, %rcx
    mov $operand_1, %al
    mul %rcx
    jmp _print

_div:
    xorq %rax, %rax
    movq $operand_2, %rcx
    movq $0, %rdx
    movq $operand_1, %rax
    div %rcx
    jmp _print