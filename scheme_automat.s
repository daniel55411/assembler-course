.data
    slash = '/'
    dash = '-'
    colon = ':'
    line_feed: .byte 0x0A
    error_message:
        .asciz "Error while parsing\n"
    l_error_message = . - error_message
    
.text
    .global _start
    
_start:
    movq 16(%rsp), %r10
    xor %r11, %r11
    xor %r12, %r12
    xor %rdi, %rdi
    jmp _scheme

_scheme:
    movq (%r10, %r11), %rax

    #check _is_latin
    movq %rip, %rdi
    add 3, %rdi
    call _is_latin
    #endcheck
    
    cmp %al, $colon
    je _check_scheme_transtition
    cmp %al, $0
    jmp _error
    inc %r11
    jmp _scheme

_check_scheme_transtition:
    cmp $colon, (%r10, %r11)
    jne _error
    inc %r11
    cmp $slash, (%r10, %r11)
    jne _error
    inc %r11
    cmp $slash, (%r10, %r11)
    jne _error
    inc %r11
    jmp _print_scheme

_print_scheme:
    #%r13 - loop counter
    #%r14 - end of printing
    movq %r11, %r14
    movq %r12, %r13
    sub 3, %r14
    call _print
    movq %r11, %r12
    jmp _host

_host:
    #%rdi check correct address
    movq (%r10, %r11), %rax

    #check _is_latin
    movq $_check_ok, %rdi
    movq %rip, %rdi
    add 3, %rdi
    call _is_latin
    #endcheck

    #check _is_digit
    movq $_check_ok, %rdi
    movq %rip, %rdi
    add 3, %rdi
    call _is_digit
    #endcheck

    #check _is_dash
    movq $_check_ok, %rdi
    xor %rdi, %rdi
    call _is_dash
    #endcheck

_check_ok:
    cmp %al, $colon
    je _check_scheme_transtition
    cmp %al, $0
    jmp _error
    inc %r11
    jmp _scheme

_is_dash:
    cmp %al, $dash
    je %rdi
    cmp $0, %rsi
    je %rsi
    jmp _error

_is_latin:
    cmp %al, 0x41
    jl _error
    cmp %al, 0x5A
    jle %rdi
    cmp %al, 0x61
    jl _error
    cmp %al, 0x7A
    jle %rdi
    cmp $0, %rsi
    je %rsi
    jmp _error

_is_digit:
    cmp %al, 0x30
    jl _error
    cmp %al, 0x39
    jle %rdi
    cmp $0, %rsi
    je %rsi
    jmp _error

_ret:
    #%rbp won't be restored
    ret

_print:
    #%r13 - loop counter
    #%r14 - end of printing
    cmp %r13, %r14
    je _print_end
    movq (%r10, %r13), %rsi
    movq $1, %rdx
    call _console_write
    inc %r13
    jmp _print

_print_end:
    movq $line_feed, %rsi
    movq $1, %rdi
    call _console_write

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
