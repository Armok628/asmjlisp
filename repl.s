.include "inclusions.s"

.globl	main
.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp

	cmpq	$1, %rdi # argc
	jng	.repl # No arguments
	movq	8(%rsi), %rdi # argv[1]
	call	read_file
	pushq	%rax
	call	eval
	call	drop
	jmp	.main_ret

	.repl:
	movl	$1024, %edi
	call	read_bytes
	pushq	%rax
	call	eval
	call	scc_terpri
	call	print
	call	drop
	call	scc_terpri
	jmp	.repl

	.main_ret:
	leave
	ret
