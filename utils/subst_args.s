self_op_str:
	.string	"@"
self_op_sym:
	.quad	1,self_op_str,0
self_op_cell:
	.quad	0,self_op_sym,0
arg_dict_seed:
	.quad	0,self_op_cell,NIL

.type	subst_args, @function
subst_args: # Stack-based. Substitutes argument symbols for bytecode flags
	# Takes two args: An argument list and function body
	call	sspush_env
	leaq	ENV(%rip), %rax
	leaq	arg_dict_seed(%rip), %rdx
	movq	%rdx, (%rax)
	# 0 stack items
	pushq	%rbx
	pushq	24(%rsp) # Recall args
	pushq	24(%rsp)
	call	swap # Arguments on top
	movq	$1, %rbx
	# 2 stack items (body | args) + %rbx
	.subst_args_def_loop:
	popq	%rdi
	call	eqnil
	cmpq	$1, %rax
	je	.subst_args_loop
	pushq	%rdi
	pushq	%rdi
	call	car
	pushq	%rbx
	call	define
	addq	$8, %rsp
	call	cdr
	incq	%rbx
	jmp	.subst_args_def_loop

	.subst_args_undef:
	addq	$8, %rsp
	call	cdr
	jmp	.subst_args_loop
	.subst_args_skip:
	addq	$8, %rsp
	call	cdr
	.subst_args_continue:
	call	cdr
	.subst_args_loop:
	# 1 stack item (body) + %rbx
	movq	(%rsp), %rdi
	call	eqnil
	cmpq	$1, %rax
	je	.subst_args_ret
	pushq	(%rsp)
	call	car
	cmpq	$0xa1, (%rsp)
	je	.subst_args_skip
	call	local_binding
	movq	(%rsp), %rdi
	call	eqnil
	cmpq	$1, %rax
	je	.subst_args_undef
	# The number is on the stack, body underneath
	call	over
	call	swap
	call	over
	call	cdr
	call	cons
	call	rplacd
	call	drop
	call	dup
	pushq	$0xaa
	call	rplaca
	call	drop
	call	cdr
	# The body from the next item on is top item on stack
	jmp	.subst_args_continue
	# 1 stack item (NIL) + %rbx
	.subst_args_ret:
	addq	$8, %rsp
	popq	%rbx
	movq	8(%rsp), %rax
	movq	%rax, 16(%rsp)
	popq	(%rsp)
	call	sspop_env
	ret
