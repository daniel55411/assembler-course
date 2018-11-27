.data
    .set WRITE, 1
    .set EXIT, 60
    msg_fail: .asciz "Not found\n"
    len_msg_fail = . - msg_fail
    msg_ok: .asciz "Ok. It was found\n"
    len_msg_ok = . - msg_ok

.text
    .globl _start

_start:
    xor %r9, %r9
    xor %r11, %r11
    movq 16(%rsp), %r8
    movq 24(%rsp), %r10

_step:
    mov (%r8, %r9), %r12b
    mov (%r10, %r11), %r13b
    cmp $0, %r13
    je _success
    cmp $0, %r12
    je _fail
    cmp %r12, %r13
    je _next
    inc %r9
    xor %r11, %r11  
    jmp _step  

_next:
    inc %r11
    inc %r9
    jmp _step

_success:
    mov $WRITE, %rax
    mov $1, %rdi
    mov $msg_ok, %rsi
    mov $len_msg_ok, %rdx
    syscall
    jmp _exit

_fail:
    mov $WRITE, %rax
    mov $1, %rdi
    mov $msg_fail, %rsi
    mov $len_msg_fail, %rdx
    syscall
    jmp _exit

_exit:
    mov $EXIT, %rax
    mov $0, %rdi
    syscall
