#---------------- DATA ----------------#
.data
	.set ADD_SYMBOL, 43
	.set SUB_SYMBOL, 45
	.set MUL_SYMBOL, 120
	.set DIV_SYMBOL, 47
	.set BUFLEN, 32
	.set WRITE, 1
    .set EXIT, 60

	buffer: .space BUFLEN
			.set end_buffer, buffer + BUFLEN - 1
	digit_error_message: 
		.asciz "Error while parsing a number\n"
	invalid_record_message: 
		.asciz "Invalid record of postfix\n"


#---------------- CODE ----------------#
.text
	.globl _start

_start:
	# %r15 - argc
    # %r14 - global counter for argv
    # %r11 - global number counter
	pop %r15
    dec %r15
    mov $0, %r14
    mov $0, %r11
    mov %rsp, %rbp

#----- MAIN BLOCK -----#
_argv_loop:
    cmp %r15, %r14
    je _print_result

    mov 8(%rbp, %r14, 8), %rbx
    call parse_argv
    push %rax
    inc %r11
    inc %r14
    jmp _argv_loop
#----- EMD MAIN BLOCK -----#

_print_result:
	cmp $1, %r11
	jne .L_invalid_record

	pop %rdi
	mov $end_buffer, %rsi
	call itoa
	mov %rax, %rdi
	call print_cstring
	jmp _exit

_exit:
    mov $EXIT, %rax
    mov $0, %rdi
    syscall
	

# Function parse_argv
#   Parse argument and handle parsed data with calc logic
# Arguments:
#   rbx:    argv prointer
# Returns:
#   rax:    parsed or calculated number
# 	rdx:	if division then fill by quotient from division
parse_argv:
	#dl - first byte
	movb (%rbx), %dl

	cmp $ADD_SYMBOL, %dl
	je	.L_add

	cmp $MUL_SYMBOL, %dl
	je .L_mul

	cmp $DIV_SYMBOL, %dl
	je .L_div

	cmp $SUB_SYMBOL, %dl
	je .L_check_minus

	jmp .L_parse_number

.L_check_minus:
	# bad solution
	mov $1, %rax
	mov (%rbx, %rax), %dl
	cmp $0, %dl
	je .L_sub
	jmp .L_parse_number #for clarity

.L_parse_number:
	# %r13 - local counter
	# %r12 - flag register for neg number
	# %r13, r12 non-volatile. should be preserved
	# rax - result
	# rsi - base
	mov $0, %r13
	mov $0, %r12
	mov $0, %rax
	mov $10, %rsi

	cmp $SUB_SYMBOL, (%rbx, %r13)
	jne .L_parse_digit

	mov $1, %r12
	inc %r13

.L_parse_digit:
	# %rcx - store byte 
	movb (%rbx, %r13), %cl

	cmp $0, %rcx
	je .L_end_parse_number

	cmp $48, %cl
	jl .L_digit_error
	cmp $57, %cl
	jg .L_digit_error

	sub $48, %cl
	mul %sil
	add %rcx, %rax
	inc %r13
	jmp .L_parse_digit

.L_end_parse_number:
	cmp $1, %r12
	jne .L_end_parse
	call .L_neg_number
.L_end_parse:
	ret

.L_neg_number:
	neg %rax
	ret

.L_add:
	call .L_extract_vars

	add %rcx, %rax
	jmp *%r13

.L_sub:
	call .L_extract_vars

	sub %rcx, %rax
	jmp *%r13

.L_mul:
	call .L_extract_vars

	imul %rcx, %rax
	jmp *%r13

.L_div:
	call .L_extract_vars

	idiv %rcx
	jmp *%r13

.L_extract_vars:
	pop %r12
	pop %r13
	pop %rcx
	pop %rax
	xor %rdx, %rdx

	sub $2, %r11
	cmp $0, %r11
	jl .L_invalid_record

	jmp *%r12

.L_digit_error:
	mov $digit_error_message, %rdi
	call print_cstring
	jmp _exit

.L_invalid_record:
	mov $invalid_record_message, %rdi
	call print_cstring
	jmp _exit



# https://eli.thegreenplace.net/2013/07/24/displaying-all-argv-in-x64-assembly
# Function print_cstring
#   Print a null-terminated string to stdout.
# Arguments:
#   rdi     address of string
# Returns: void
print_cstring:
    mov %rdi, %r10
.L_find_null:
    cmpb $0, (%r10)
    je .L_end_find_null
    inc %r10
    jmp .L_find_null
.L_end_find_null:
    sub %rdi, %r10

    mov $1, %rax
    mov %rdi, %rsi
    mov $1, %rdi
    mov %r10, %rdx
    syscall
    ret

# https://eli.thegreenplace.net/2013/07/24/displaying-all-argv-in-x64-assembly
# Function itoa
#   Convert an integer to a null-terminated string in memory.
#   Assumes that there is enough space allocated in the target
#   buffer for the representation of the integer. Since the number itself
#   is accepted in the register, its value is bounded.
# Arguments:
#   rdi:    the integer
#   rsi:    address of the *last* byte in the target buffer
# Returns:
#   rax:    address of the first byte in the target string that
#           contains valid information.
itoa:
    movb $0, (%rsi) 

    mov $0, %r9
    cmp $0, %rdi
    jge .L_input_positive
    neg %rdi
    mov $1, %r9
.L_input_positive:

    mov %rdi, %rax
    mov $10, %r8

.L_next_digit:
    xor %rdx, %rdx
    div %r8
    dec %rsi
    add $0x30, %dl
    movb %dl, (%rsi)

    cmp $0, %rax
    jne .L_next_digit

    cmp $1, %r9
    jne .L_itoa_done
    dec %rsi
    movb $0x2d, (%rsi)

.L_itoa_done:
    mov %rsi, %rax
    ret
