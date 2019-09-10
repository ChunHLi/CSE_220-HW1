# Homework #1
# name: Chun_Hung_Li
# sbuid: 110807126

# notes
# The $a0 register contains the number of arguments passed to your program.
# The $a1 register contains the starting address of an array of strings.
# Each element in the array is the starting address of the argument specified on the command line.

.data

.align 2
	numargs: .word 0
	integer: .word 0
	fromBase: .word 0
	toBase: .word 0
	Err_string: .asciiz "ERROR\n"
	OK_string: .asciiz "OK"
	# buffer is 32 space characters
	buffer: .ascii "                                "
	newline: .asciiz "\n"
	convertedInteger: .word 0
	
# Helper macro for grabbing command line arguments
# After the load_args macro finishes, integer, fromBase and toBase hold the values given by the args
.macro load_args
	sw $a0, numargs
	lw $t0, 0($a1)
	sw $t0, integer
	lw $t0, 4($a1)
	sw $t0, fromBase
	lw $t0, 8($a1)
	sw $t0, toBase
.end_macro

.text
.globl main
main:
	load_args() # Only do this once
	li $t1, 3 # stores int value 3 into register t1
	bne $a0, $t1, Error # if the number of args doesn't equal 3, jump to Numargs_Error otherwise proceed to reading args
	
	li $t3, 50 # ascii value for base 2
	li $t4, 57 # ascii value for base 9
	li $t5, 65 # ascii value for base 10 or A
	li $t6, 70 # ascii value for base 15 or F
	
	lw $a1, fromBase # load word of original base
	lb $t1, 0($a1) # load first byte of og base
	blt $t1, $t3, Error # if byte is less than 50, go to Error
	bgt $t1, $t6, Error # if byte is greater than 70, go to Error
	bgt $t1, $t4, isAF # if byte is greater than 57, we need to check if it's in between isAF
	addi $t1, $t1, -48 # converts t1's ascii value to dec value
	addi $t7, $t1, 0 # stores t1 into t7
	j nextCheck # since byte is less than or equal to 57, we can move on to checking the next base
	
	isAF:
	blt $t1, $t5, Error # if the byte is less than 65 and greater than 57, it isn't valid
	addi $t1, $t1, -55 # converts t1's ascii value to hex value
	addi $t7, $t1, 0 # stores t1 into t7
	
	nextCheck:
	lw $a2, toBase # load word of next base
	lb $t2, 0($a2) #load first byte of next base
	blt $t2, $t3, Error # if byte is less than 50, go to Error
	bgt $t2, $t6, Error # if byte is greater than 70, go to Error
	bgt $t2, $t4, isAFtoo
	addi $t2, $t2, -48 # converts t1's ascii value to dec value
	addi $t8, $t2, 0
	j nextChecktoo
	
	isAFtoo:
	blt $t2, $t5, Error # if the byte is less than 65 and greater than 57, it isn't valid
	addi $t2, $t2, -55 # converts t1's ascii value to hex value
	addi $t8, $t2, 0
	
	nextChecktoo:
	addi $a1, $a1, 1 # increment pointer
	lb $t1, 0($a1) # load character of og base
	addi $a2, $a2, 1 # increment pointer
	lb $t2, 0($a2) # load character of nt base
	bgt $t1, $0, Error # if the next byte is greater than zero ergo, not null, go to error (base size should be one character)
	bgt $t2, $0, Error # if the next byte is greater than zero ergo, not null, go to error (base size should be one character)
	
	lw $s1, integer
	move $t1, $0 # byte storage for t1
	move $t2, $0 # stores counter
	xor $s2, $s2, $s2 # stored values for converted bytes
	convertASCII:         
  	lbu $t1, ($s1)       # load unsigned char from array into t1
  	beq $t1, $0, reverse # NULL terminator found
  	blt $t1, 48, Error   # check if char is not less than 0 (ascii<'0')
  	bgt $t1, 69, Error   # check if char is not greater than 69 (ascii>'9')
  	bgt $t1, 57, isAFthree #check if chat is a digit, if not check if A-E
  	j convertASCIIdigits
  	isAFthree:
  	blt $t1, 65, Error
  	j convertASCIIhex
  	
  	convertASCIIdigits:
  	sll $s2, $s2, 4 # shift left logical by 4
  	addi $t1, $t1, -48   # converts t1's ascii value to dec value
  	or $s2, $t1, $s2     # stores byte's dec value
  	addi $s1, $s1, 1     # increment array address
  	addi $t2, $t2, 1     # add one counter
  	j convertASCII       # jump to start of loop
  	
  	convertASCIIhex:
  	sll $s2, $s2, 4 # shift left logical by 4
  	addi $t1, $t1, -55 # converts t1's ascii value to hex value
  	or $s2, $t1, $s2     # stores byte's hex value
  	addi $s1, $s1, 1 # increment array address
  	addi $t2, $t2, 1     # add one counter
  	j convertASCII # jump to start of loop
  	
  	reverse:
  	move $t1, $0
  	pool:
  	beqz $s2, prepareBaseToDecimal # NULL terminator found
  	sll $s3, $s3, 4 # shift left logical by 4
  	move $t1, $s2 # moves 
  	sll $t1, $t1, 28
  	srl $t1, $t1, 28
  	or $s3, $t1, $s3 # sore byte's hex value
  	srl $s2, $s2, 4 # delete first byte
  	j pool # jump to start of pool
	
	prepareBaseToDecimal:
	li $s4, 1
	li $t9, 0
	j fromBaseToDecimalLoop
	
	fromBaseToDecimalLoop:
    beqz $t2, fromDecimalToBaseLoop # if the counter we recorded in convertASCII becomes zero, move on to fromDecimalToBaseLoop
    move $s0, $s3 # copy reversedInt into $s0
    sll $s0, $s0, 28 # delete first 28 bits of $s0
    srl $s0, $s0, 28 # move the remaining bit to the lsb
    mult $t9, $s4 # algorithm for base conversion
    mflo $t9 # algorithm for base conversion
    add $t9, $t9, $s0 # algorithm for base conversion
    srl $s3, $s3, 4 # delete first byte
    addi $t2, $t2, -1 # decrement counter
    move $s4, $t7 # copy the original base
    ble $s4, $s0, Error # if the base is less than or equal to the digit, end program and print error
    j fromBaseToDecimalLoop
	
	fromDecimalToBaseLoop:
	blez $t9, rereverse # once the decimal is less than or equal to 0, proceed to convertComplete
	div $t9, $t8 
	mfhi $s6 # remainder
	mflo $t9 # quotient
	sll $s5, $s5, 4 #
	or $s5, $s6, $s5 # combine bytes
	j fromDecimalToBaseLoop
	
	rereverse:
  	move $t1, $0
  	move $s3, $0
  	poool:
  	beqz $s5, intoBuffer # NULL terminator found
  	sll $s3, $s3, 4 # shift left logical by 4
  	move $t1, $s5 # moves 
  	sll $t1, $t1, 28
  	srl $t1, $t1, 28
  	or $s3, $t1, $s3 # sore byte's hex value
  	srl $s5, $s5, 4 # delete first byte
  	j poool # jump to start of pool
	
	intoBuffer:
	move $s1, $0
	move $s5, $0
	la $s1, buffer
	looop:
	beqz $s3, convertComplete
	move $s5, $s3
	sll $s5, $s5, 28
	srl $s5, $s5, 28
	bgt $s5, 9, hex
	addi $s5, $s5, 48
	j skipHex
	hex:
	addi $s5, $s5, 55
	skipHex:
	#insert a way to add the ascii into buffer
	sb $s5, 32($s1)
	srl $s3, $s3, 4
	addi $s1, $s1, -1
	j looop
	
	convertComplete:
	li $v0, 4
	la $a0, buffer
	syscall
	j Terminate # output is printed so terminate program
	
	Error:
	li $v0, 4 # prepare syscall to print string
	la $a0, Err_string # tells syscall what to print
	syscall
	j Terminate #Err_String is printed so terminate program
	
	#terminates the program
	Terminate:
	li $v0, 10 
	syscall
