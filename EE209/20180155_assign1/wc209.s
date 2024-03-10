	.file	"wc209.c"
	.text
	.comm	c,4,4
	.globl	nLines
	.bss
	.align 4
	.type	nLines, @object
	.size	nLines, 4
nLines:
	.zero	4
	.globl	nWords
	.align 4
	.type	nWords, @object
	.size	nWords, 4
nWords:
	.zero	4
	.globl	nCharacters
	.align 4
	.type	nCharacters, @object
	.size	nCharacters, 4
nCharacters:
	.zero	4
	.globl	line_of_error
	.align 4
	.type	line_of_error, @object
	.size	line_of_error, 4
line_of_error:
	.zero	4
	.globl	state
	.align 4
	.type	state, @object
	.size	state, 4
state:
	.zero	4
	.text
	.globl	space
	.type	space, @function
space:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	call	__ctype_b_loc@PLT
	movq	(%rax), %rax
	movl	c(%rip), %edx
	movslq	%edx, %rdx
	addq	%rdx, %rdx
	addq	%rdx, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %eax
	andl	$8192, %eax
	testl	%eax, %eax
	je	.L2
	movl	c(%rip), %eax
	cmpl	$10, %eax
	jne	.L3
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L5
.L3:
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L5
.L2:
	movl	c(%rip), %eax
	cmpl	$47, %eax
	jne	.L6
	movl	$4, state(%rip)
	movl	nWords(%rip), %eax
	addl	$1, %eax
	movl	%eax, nWords(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L5
.L6:
	movl	$1, state(%rip)
	movl	nWords(%rip), %eax
	addl	$1, %eax
	movl	%eax, nWords(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
.L5:
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	space, .-space
	.globl	nonspace
	.type	nonspace, @function
nonspace:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	call	__ctype_b_loc@PLT
	movq	(%rax), %rax
	movl	c(%rip), %edx
	movslq	%edx, %rdx
	addq	%rdx, %rdx
	addq	%rdx, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %eax
	andl	$8192, %eax
	testl	%eax, %eax
	je	.L9
	movl	c(%rip), %eax
	cmpl	$10, %eax
	jne	.L10
	movl	$0, state(%rip)
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L12
.L10:
	movl	$0, state(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L12
.L9:
	movl	c(%rip), %eax
	cmpl	$47, %eax
	jne	.L13
	movl	$3, state(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L12
.L13:
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
.L12:
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	nonspace, .-nonspace
	.globl	nonspace_slash
	.type	nonspace_slash, @function
nonspace_slash:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	call	__ctype_b_loc@PLT
	movq	(%rax), %rax
	movl	c(%rip), %edx
	movslq	%edx, %rdx
	addq	%rdx, %rdx
	addq	%rdx, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %eax
	andl	$8192, %eax
	testl	%eax, %eax
	je	.L16
	movl	c(%rip), %eax
	cmpl	$10, %eax
	jne	.L17
	movl	$0, state(%rip)
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L19
.L17:
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L19
.L16:
	movl	c(%rip), %eax
	cmpl	$42, %eax
	jne	.L20
	movl	$2, state(%rip)
	movl	nLines(%rip), %eax
	movl	%eax, line_of_error(%rip)
	jmp	.L19
.L20:
	movl	c(%rip), %eax
	cmpl	$47, %eax
	jne	.L21
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L19
.L21:
	movl	$1, state(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
.L19:
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	nonspace_slash, .-nonspace_slash
	.globl	space_slash
	.type	space_slash, @function
space_slash:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	call	__ctype_b_loc@PLT
	movq	(%rax), %rax
	movl	c(%rip), %edx
	movslq	%edx, %rdx
	addq	%rdx, %rdx
	addq	%rdx, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %eax
	andl	$8192, %eax
	testl	%eax, %eax
	je	.L24
	movl	c(%rip), %eax
	cmpl	$10, %eax
	jne	.L25
	movl	$0, state(%rip)
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L27
.L25:
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L27
.L24:
	movl	c(%rip), %eax
	cmpl	$42, %eax
	jne	.L28
	movl	$2, state(%rip)
	movl	nLines(%rip), %eax
	movl	%eax, line_of_error(%rip)
	movl	nWords(%rip), %eax
	subl	$1, %eax
	movl	%eax, nWords(%rip)
	jmp	.L27
.L28:
	movl	c(%rip), %eax
	cmpl	$47, %eax
	jne	.L29
	movl	$3, state(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L27
.L29:
	movl	$1, state(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
.L27:
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	space_slash, .-space_slash
	.globl	comment
	.type	comment, @function
comment:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	c(%rip), %eax
	cmpl	$42, %eax
	jne	.L32
	movl	$5, state(%rip)
	jmp	.L33
.L32:
	movl	c(%rip), %eax
	cmpl	$10, %eax
	jne	.L33
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
.L33:
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	comment, .-comment
	.globl	comment_star
	.type	comment_star, @function
comment_star:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	c(%rip), %eax
	cmpl	$47, %eax
	jne	.L36
	movl	$0, state(%rip)
	movl	$0, line_of_error(%rip)
	jmp	.L37
.L36:
	movl	c(%rip), %eax
	cmpl	$10, %eax
	jne	.L38
	movl	$2, state(%rip)
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	movl	nCharacters(%rip), %eax
	addl	$1, %eax
	movl	%eax, nCharacters(%rip)
	jmp	.L37
.L38:
	movl	c(%rip), %eax
	cmpl	$42, %eax
	jne	.L39
	movl	$5, state(%rip)
	jmp	.L37
.L39:
	movl	$2, state(%rip)
.L37:
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	comment_star, .-comment_star
	.section	.rodata
.LC0:
	.string	"%d %d %d"
.LC1:
	.string	"wc209.c"
.LC2:
	.string	"0"
	.align 8
.LC3:
	.string	"Error: line %d: unterminated comment\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	call	getchar@PLT
	movl	%eax, c(%rip)
	movl	c(%rip), %eax
	cmpl	$-1, %eax
	je	.L42
	movl	nLines(%rip), %eax
	addl	$1, %eax
	movl	%eax, nLines(%rip)
	call	space
	jmp	.L45
.L42:
	movl	nCharacters(%rip), %esi
	movl	nWords(%rip), %ecx
	movl	nLines(%rip), %edx
	movq	stdout(%rip), %rax
	movl	%esi, %r8d
	leaq	.LC0(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$0, %eax
	jmp	.L44
.L54:
	movl	state(%rip), %eax
	cmpl	$5, %eax
	ja	.L46
	movl	%eax, %eax
	leaq	0(,%rax,4), %rdx
	leaq	.L48(%rip), %rax
	movl	(%rdx,%rax), %eax
	movslq	%eax, %rdx
	leaq	.L48(%rip), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section	.rodata
	.align 4
	.align 4
.L48:
	.long	.L47-.L48
	.long	.L49-.L48
	.long	.L50-.L48
	.long	.L51-.L48
	.long	.L52-.L48
	.long	.L53-.L48
	.text
.L47:
	call	space
	jmp	.L45
.L49:
	call	nonspace
	jmp	.L45
.L51:
	call	nonspace_slash
	jmp	.L45
.L52:
	call	space_slash
	jmp	.L45
.L50:
	call	comment
	jmp	.L45
.L53:
	call	comment_star
	jmp	.L45
.L46:
	leaq	__PRETTY_FUNCTION__.2232(%rip), %rcx
	movl	$134, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC2(%rip), %rdi
	call	__assert_fail@PLT
.L45:
	call	getchar@PLT
	movl	%eax, c(%rip)
	movl	c(%rip), %eax
	cmpl	$-1, %eax
	jne	.L54
	movl	state(%rip), %eax
	cmpl	$2, %eax
	je	.L55
	movl	state(%rip), %eax
	cmpl	$5, %eax
	jne	.L56
.L55:
	movl	line_of_error(%rip), %edx
	movq	stderr(%rip), %rax
	leaq	.LC3(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$1, %eax
	jmp	.L44
.L56:
	movl	nCharacters(%rip), %esi
	movl	nWords(%rip), %ecx
	movl	nLines(%rip), %edx
	movq	stdout(%rip), %rax
	movl	%esi, %r8d
	leaq	.LC0(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$0, %eax
.L44:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.section	.rodata
	.type	__PRETTY_FUNCTION__.2232, @object
	.size	__PRETTY_FUNCTION__.2232, 5
__PRETTY_FUNCTION__.2232:
	.string	"main"
	.ident	"GCC: (Ubuntu 7.3.0-16ubuntu3) 7.3.0"
	.section	.note.GNU-stack,"",@progbits
