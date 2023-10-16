### --------------------------------------------------------------------
### mydc.s
###
### Desk Calculator (dc)
### --------------------------------------------------------------------

	.equ   ARRAYSIZE, 20
	.equ   EOF, -1
	.equ   ZERO, 0x30
	.equ   NINE, 0x39
	.equ   p, 0x70
	.equ   q, 0x71
	.equ   f, 0x66	
	.equ   c, 0x63
	.equ   d, 0x64
	.equ   r, 0x72
	.equ   NEGATIVE, 0x5f
	.equ   PLUS, 0x2b 
	.equ   MINUS, 0x2d
	.equ   POWER, 0x5e
	.equ   MULT, 0x2a
	.equ   REMAINDER, 0x25
	.equ   DIVISION, 0x2f
	
.section ".rodata"

printfDebug:
	.asciz "00000\n"
scanfFormat:
	.asciz "%s"
printfInteger:
	.asciz "%d\n"
printfCharacter:
	.asciz "%c\n"
emptyStack:
	.asciz "dc: stack empty\n"


### --------------------------------------------------------------------

        .section ".data"

### --------------------------------------------------------------------

        .section ".bss"

buffer:
        .skip  ARRAYSIZE
iexp:
	.skip  4
ibase:
	.skip  4
idivisor:
	.skip  4
idividend:
	.skip  4
icount:
	.skip  4
itotal:
	.skip  4
iindex:
	.skip  4
original_esp:	
	.skip  4
original_ebp:
	.skip  4

	
### --------------------------------------------------------------------

	.section ".text"

	## -------------------------------------------------------------
	## int main(void)
	## Runs desk calculator program.  Returns 0.
	## -------------------------------------------------------------

	.globl  main
	.type   main,@function


main:
	pushl   %ebp
	movl    %esp, %ebp

input:
	## dc number stack initialized. %esp = %ebp
	
	## scanf("%s", buffer)
	pushl	$buffer
	pushl	$scanfFormat
	call    scanf
	addl    $8, %esp  

	## check if user input EOF
	cmp	$EOF, %eax
	je	quit

	## finding the first element of buffer
	movl	$0, %eax
	addl	$buffer, %eax
	movb    (%eax), %dl

	## now %dl has the first character
	## check if fist character is digit or not
	
	cmp	$ZERO, %dl
	jl	not_digit
	cmp 	$NINE, %dl
	jg	not_digit
	jmp	when_digit

not_digit:	
	cmp 	$p, %dl
	je	print_top
	cmp     $q, %dl
	je 	quit
	cmp     $NEGATIVE, %dl
	je	negative
	cmp   	$PLUS, %dl
	je 	plus 
	cmp   	$MINUS, %dl 
	je	minus
	cmp   	$POWER, %dl
	je	power
	cmp   	$MULT, %dl  
	je	multiple
	cmp   	$REMAINDER, %dl
	je	remainder
	cmp   	$DIVISION, %dl
	je	division
	cmp	$f, %dl
	je	print_stack
	cmp	$c, %dl
	je	clear
	cmp	$d, %dl
	je	duplicate
	cmp	$r, %dl
	je	reverse
	jmp 	input

plus:
	cmp 	%esp, %ebp
	je 	print_empty	
	popl	%ebx
	cmp 	%esp,%ebp
	je	print_empty_2
	popl	%edx
	addl	%ebx, %edx
	pushl	%edx
	jmp	input

minus:
 	cmp 	%esp, %ebp
	je 	print_empty	
	popl	%ebx
	cmp 	%esp,%ebp
	je	print_empty_2
	popl	%edx
	subl	%ebx, %edx
	pushl	%edx
	jmp	input

power:
	cmp 	%esp, %ebp
	je 	print_empty	
	popl	%ebx
	movl	%ebx, iexp
	cmp 	%esp,%ebp
	je	print_empty_2
	popl	%edx
	movl	%edx, ibase

	movl	$1, icount
	movl	$1, itotal	

	power_loop:
	 	movl  icount, %eax 
   		cmpl  iexp, %eax   
    		jg    power_loop_end     

    		movl  itotal, %eax 
    		imull ibase         
    		movl  %eax, itotal  
    		incl  icount
   		jmp   power_loop

	power_loop_end:
		pushl	itotal
		jmp	input

multiple:
	cmp 	%esp, %ebp
	je 	print_empty	
	popl	%ebx
	cmp 	%esp,%ebp
	je	print_empty_2
	popl	%edx

	movl	%ebx, %eax
	mull	%edx
	pushl	%eax
	jmp	input

remainder:
	cmp 	%esp, %ebp
	je 	print_empty	
	popl    %ebx
	movl	%ebx, idivisor
	cmp 	%esp,%ebp
	je	print_empty_2
	popl	idividend
	movl	idivisor, %ebx
	movl	idividend, %eax
	cdq
	idivl	%ebx	
	cmp	$0, %edx
	jl	negative_rem		 	
	pushl 	%eax
	jmp	input

negative_rem:
	addl 	idivisor, %edx
	pushl	%edx
	jmp	input

division:
	cmp 	%esp, %ebp
	je 	print_empty	
	popl    %ebx
	movl	%ebx, idivisor
	cmp 	%esp,%ebp
	je	print_empty_2
	popl	idividend
	movl	idivisor, %ebx
	movl	idividend, %eax
	cdq
	idivl	%ebx
	cmp	$0, %eax
	jl	negative_quo 		 	
	pushl 	%eax
	jmp	input

negative_quo:
	decl	%eax
	pushl 	%eax
	jmp	input

print_stack:
	movl	 %esp, original_esp
	movl 	$0, iindex
	print_stack_loop:
 		addl	iindex, %esp
		cmp	%esp, %ebp		
		je	print_stack_loop_end
		movl	(%esp), %ebx
		subl	iindex, %esp
		pushl	%ebx
		pushl	$printfInteger
		call	printf
		addl	$8, %esp
		addl	$4, iindex
		jmp	print_stack_loop
	
	print_stack_loop_end:
		movl	original_esp, %esp
		jmp	input	
					
clear:
	cmp	%esp, %ebp		
	je	input
	popl	%eax		
	jmp	clear	


duplicate:
	cmp	%esp, %ebp
	je	print_empty
	popl	%edx
	pushl	%edx
	pushl 	%edx
	jmp	input

reverse:
	cmp	%esp, %ebp
	je	print_empty
	popl	%ebx
	cmp	%esp, %ebp
	je	print_empty_2
	popl	%edx
	pushl	%ebx
	pushl	%edx
	jmp 	input

negative:
	movl	$buffer, %eax	 
	addl	$1, %eax ## we have to ignore the very first.
	pushl	%eax	
	call	atoi
	addl	$4, %esp
	movl	%eax, %edx
	subl	%edx, %eax
	subl	%edx, %eax
	pushl 	%eax
	jmp	input

		
when_digit:
	pushl	$buffer
	call	atoi
	addl	$4, %esp
	pushl 	%eax
	jmp	input


print_top:
	cmp 	%esp, %ebp
	je 	print_empty
	movl	(%esp), %ebx
	pushl	%ebx
	pushl	$printfInteger
	call 	printf
	addl 	$8, %esp
	jmp 	input
	
print_empty:	
	pushl	$emptyStack
	call	printf
	addl	$4, %esp
	jmp	input

print_empty_2:
	pushl	%ebx
	pushl	$emptyStack
	call	printf
	addl	$4, %esp
	jmp	input

quit:	
	## return 0
	movl    $0, %eax
	movl    %ebp, %esp
	popl    %ebp
	ret
