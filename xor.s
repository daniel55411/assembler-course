.data
	.set N, 100
	.set CLOSE, 3
	.set OPEN, 2
	.set WRITE, 1
	.set READ, 0
	.set EXIT, 60
	.set O_RDONLY, 0
	.set O_WRONLY, 1
	msg:
		.ascii "Error!\n"
	len = . - msg
	filename: .asciz "test.txt"
	buffer: .skip N

.text
	.globl _start

_start:
	movq $OPEN, %rax
	mov 16(%rsp), %rdi
	mov $O_RDONLY, %rsi
	syscall
	cmp $0, %rax
	jl _error

	mov %rax, %rdi
	mov $READ, %rax
	mov $buffer, %rsi
	mov $N, %rdx
	syscall	

	mov %rax, %r9
	mov %rax, %rcx
	mov 32(%rsp), %r10
	mov (%r10), %r10
_xor:
	cmp $0, %rcx
	dec %rcx
	je _write_file
	xor %r10, (%rsi)
	inc %rsi
	jmp _xor

_write_file:
	movq $OPEN, %rax
	mov 24(%rsp), %rdi
	mov $O_WRONLY, %rsi
	syscall
	cmp $0, %rax
	jl _error

	mov %rax, %rdi
	mov $WRITE, %rax
	mov $buffer, %rsi
	mov %r9, %rdx
	syscall	

	mov %rax, %rdi
	mov $CLOSE, %rax
	syscall

	call _exit

_error:
	mov $WRITE, %rax
	mov $1, %rdi
	mov $msg, %rsi
	mov $len, %rdx
	syscall
	
_exit:
	mov $EXIT, %rax
	mov $0, %rdi
	syscall	


