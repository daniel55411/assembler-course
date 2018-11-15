.data
	.set N, 101
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
	buffer: .skip N

.text
	.globl _start

_start:

_len:
	movb $0, %al
	movq 16(%rsp), %rdi
	movq $N, %rcx
repne scasb 
	je _success

_success:
	

_exit:
	mov $EXIT, %rax
	mov $0, %rdi
	syscall
