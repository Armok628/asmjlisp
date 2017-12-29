# Original: (defun rpn (l) (if (atom l) (cons l nil) (nconc (maprpn (cdr l)) (rpn (car l)))))
.type	rpn, @function
rpn:
	cmpq	$0xff, 8(%rsp)
	jle	.rpn_atom # Pretend that a flag is an atom
	movq	8(%rsp), %rax
	cmpq	$0, (%rax)
	jnz	.rpn_atom
	pushq	8(%rsp)
	call	car
	leaq	dict_cond_sym(%rip), %rax
	pushq	%rax
	call	eq
	popq	%rdi
	call	zornil
	cmpq	$1, %rax
	jne	.rpn_cond
	pushq	8(%rsp)
	call	car
	leaq	dict_quote_sym(%rip), %rax
	pushq	%rax
	call	eq
	popq	%rdi
	call	zornil
	cmpq	$1, %rax
	jne	.rpn_quote # Treat quoted lists as atoms
	pushq	8(%rsp)
	pushq	(%rsp)
	pushq	(%rsp)
	call	cdr
	call	swap
	call	car
	call	reference
	popq	%rax
	cmpq	$4, (%rax)
	jne	.rpn_unspecial
	pushq	$0
	call	swap
	call	cons
	.rpn_unspecial:
	call	maprpn
	call	swap
	call	car
	call	rpn
	call	nconc
	jmp	.rpn_ret
	.rpn_cond:
	pushq	8(%rsp)
	call	prep_cond
	call	rpn
	jmp	.rpn_ret
	.rpn_quote:
	pushq	$0xa1
	pushq	16(%rsp)
	call	cdr
	call	cons
	jmp	.rpn_ret
	.rpn_atom:
	pushq	8(%rsp)
	####################
	call	dup
	leaq	dict_return_sym(%rip), %rax
	pushq	%rax
	call	eq
	popq	%rdi
	call	zornil
	cmpq	$1, %rax
	je	.rpn_atom_no_return
	addq	$8, %rsp
	pushq	$0xee
	.rpn_atom_no_return:
	####################
	leaq	NIL(%rip), %rax
	pushq	%rax
	call	cons
	.rpn_ret:
	popq	8(%rsp)
	ret

# Original: (defun maprpn (l) (if (atom l) l (nconc (rpn (car l)) (maprpn (cdr l)))))
.type	maprpn, @function
maprpn:
	movq	8(%rsp), %rax
	cmpq	$0, %rax
	jz	.maprpn_atom
	cmpq	$0, (%rax)
	jnz	.maprpn_atom
	pushq	%rax
	pushq	%rax
	call	car
	call	rpn
	call	swap
	call	cdr
	call	maprpn
	call	nconc
	popq	8(%rsp)
	.maprpn_atom:
	ret
