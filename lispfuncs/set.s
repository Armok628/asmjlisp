.type	set, @function #|set|
set: # Stack-based
	movq	16(%rsp), %rdi
	cmpq	NILptr(%rip), %rdi
	je	.set_err
	cmpq	T(%rip), %rdi
	je	.set_err

	movq	16(%rsp), %rdi
	movq	8(%rsp), %rsi

	movq	(%rsi), %rax
	movq	%rax, (%rdi)

	movq	8(%rsi), %rax
	movq	%rax, 8(%rdi)

	movq	16(%rsi), %rax
	movq	%rax, 16(%rdi)

	popq	(%rsp)

	.set_err:
	ret
