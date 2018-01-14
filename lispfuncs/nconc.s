.type	nconc, @function #|nconc|
nconc:
	pushq	16(%rsp) # Fetch the list
	movq	(%rsp), %rdi
	cmpq	NILptr(%rip), %rdi
	je	.nconc_nil
	.nconc_loop:
	call	dup
	call	cdr
	movq	(%rsp), %rdi
	cmpq	NILptr(%rip), %rdi
	call	drop
	je	.nconc_do
	call	cdr
	jmp	.nconc_loop
	.nconc_do:
	popq	%rdi
	movq	8(%rsp), %rax
	movq	%rax, 16(%rdi)
	popq	(%rsp) # Nip
	ret
	.nconc_nil: # (nconc nil a) => a
	call	drop
	movq	8(%rsp), %rax
	movq	%rax, 16(%rsp)
	call	nip
	ret
