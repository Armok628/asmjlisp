.include "inclusions.s"

.globl	main
.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp

	movl	$100, %edi
	movl	$2, %esi
	call	new_var
	pushq	%rax
	call	lread
	call	dup
	call	print
	call	drop
	call	terpri
	call	prep_cond
	call	dup
	call	print
	call	drop
	call	terpri
	call	rpn
	call	print
	call	drop
	call	terpri

	leave
	ret
