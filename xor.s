.data
.set N, 100
.set OPEN, 2
.set WRITE, 1
.set READ, 0
.set EXIT, 60
.set O_RDONLY, 0
msg:
.ascii "Error!\n"
len = . - msg
filename: .asciz "1.txt"
buffer: .skip N
.text
.globl _start
_start:
	mov $OPEN, %rax
	lea filename, %rdi
	mov $O_RDONLY, %rsi
	syscall
	cmp $0, %rax
	jl _error

	mov %rax, %rdi
	mov $READ, %rax
	mov $buffer, %rsi
	mov $N, %rdx
	syscall	

	mov $WRITE, %rax
	mov $1, %rdi
	mov $buffer, %rsi
	mov $N, %rdx
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
