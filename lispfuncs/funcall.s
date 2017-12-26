.type	funcall, @function
funcall:
	pushq	%rax
	pushq	%rcx
	pushq	%rbp
	movq	%rsp, %rbp
	movq	32(%rsp), %rax # Load pointer to function (past return addr/backups)
	movq	$1, %rcx # Set the counter to 1 (At 0 would be # of args)
	.funcall_loop:
	movq	(%rax,%rcx,8), %rdx # Load the next instruction
	cmpq	$0xa1, %rdx
	jz	.funcall_pushq
	cmpq	$0xaa, %rdx
	je	.funcall_pusharg
	cmpq	$0xca, %rdx
	je	.funcall_call
	cmpq	$0xee, %rdx
	je	.funcall_exit
	# It is assumed at this point that the instruction must be a function pointer
	.funcall_asmcall:
	# Need to preserve function and counter.
	# The new solution for this is good, but unnecessary unless a core function calls funcall
	# As a result, this might change in the future.
	call	sspush_a_c
	call	*%rdx
	call	sspop_a_c
	incq	%rcx
	jmp	.funcall_loop
	.funcall_pushq:
	incq	%rcx
	movq	(%rax,%rcx,8), %rdx # Load the literal to be pushed
	pushq	%rdx
	incq	%rcx
	jmp	.funcall_loop
	.funcall_pusharg:
	incq	%rcx
	movq	(%rax), %rdx # -(# of args + 1)
	negq	%rdx
	subq	(%rax,%rcx,8), %rdx # Get argument offset
	addq	$4, %rdx # Skip return address, base pointer, and rax/rcx backups
	pushq	(%rbp,%rdx,8)
	incq	%rcx
	jmp	.funcall_loop
	.funcall_call:
	incq	%rcx
	movq	(%rax,%rcx,8), %rdx # Load the function to be called
	cmpq	$3, (%rdx)
	jge	.funcall_asmfunc
	pushq	%rdx
	call	funcall
	incq	%rcx
	jmp	.funcall_loop
	.funcall_asmfunc:
	movq	8(%rdx), %rdx
	jmp	.funcall_asmcall
	.funcall_exit:
	# At this point there must only be one thing on the stack
	popq	%rdi # Take that thing off the stack
	# Now the stack should be the way it was before .funcall_loop
	movq	%rbp, %rsp # Reset the stack
	popq	%rbp # (see above)
	movq	8(%rsp), %rax # Recall function
	movq	(%rax), %rdx # Store the number of variables
	negq	%rdx # (see above)
	decq	%rdx # (see above)
	movq	$8, %rax
	mulq	%rdx
	movq	%rax, %rdx  # Store number of bytes worth of variables
	popq	%rcx # Pick up backed up registers
	popq	%rax # (see above)
	popq	%rsi # Preserve return address
	addq	%rdx, %rsp
	pushq	%rdi
	pushq	%rsi
	ret
	.funcall_ret:
	movq	%rdx, 8(%rsp) # Replace final arg with return value
	ret
