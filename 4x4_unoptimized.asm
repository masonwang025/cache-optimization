.text
start:
	# READ INPUT
	# matrix 1
	la $a0, M1
	jal read_matrix
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	# matrix 2
	la $a0, M2
	jal read_matrix
	
	li $v0, 4
	la $a0, new_line
	syscall
	
	# matrix multiply
	la $a2, M2
	la $a1, M1
	la $a0, product
	# M1 * M2 -> product
	jal matrix_multiply
	
	# print output
	la $a0, product
	jal print_matrix

	# print sum
	la $a0, product
	jal sum_matrix # sum will be in $v0
	move $a0, $v0 # a0 contains the sum
	li $v0, 1 
	syscall
	
	
	# exit
	li $v0, 10
	syscall


# a1 * a2 -> a0
matrix_multiply:
	move $s3, $a0 # product
	move $s4, $a1 # M1
	move $s5, $a2 # M2
	
	li $s0, 0 # i = 0; initialize 1st for loop
	L1: li $s1, 0 # j = 0; restart 2nd for loop
		L2: li $s2, 0 # k = 0; restart 3rd for loop
		sll $s3, $s0, 2 # $s3 = i * 4 (size of row of c)
		addu $s3, $s3, $s1 # $s3 = i * size(row) + j
		sll $s3, $s3, 2 # $s3 = byte offset of [i][j]
		addu $s3, $a0, $s3 # $s3 = byte address of c[i][j]
		lw $s5, 0($s3) # $s5 = 8 bytes of c[i][j]
		L3: # inner loop
            sll $t0, $s2, 2 # $t0 = k * 4 (size of row of b)
            addu $t0, $t0, $s1 # $t0 = k * size(row) + j
            sll $t0, $t0, 2 # $t0 = byte offset of [k][j]
            addu $t0, $a2, $t0 # $t0 = byte address of b[k][j]
            lw $t5, 0($t0) # $t5 = 8 bytes of b[k][j]
            sll $t0, $s0, 2 # $t0 = i * 4 (size of row of a)
            addu $t0, $t0, $s2 # $t0 = i * size(row) + k
            sll $t0, $t0, 2 # $t0 = byte offset of [i][k]
            addu $t0, $s4, $t0 # $t0 = byte address of a[i][k]
            lw $t6, 0($t0) # $t6 = 8 bytes of a[i][k]
            mul $t5, $t6, $t5 # $t5 = a[i][k] * b[k][j]
            add $s5, $s5, $t5 # s5 = c[i][j] + a[i][k] * b[k][j]
            addiu $s2, $s2, 1 # $k = k + 1
            bne $s2, 4, L3 # if (k != 4) go to L3
            sw $s5, 0($s3) # c[i][j] = $s5
            addiu $s1, $s1, 1 # $j = j + 1
            bne $s1, 4, L2 # if (j != 4) go to L2
            addiu $s0, $s0, 1 # $i = i + 1
            bne $s0, 4, L1 # if (i != 4) go to L1
	jr $ra


# procedure that reads a 4x4 matrix into $a0
read_matrix:
	li $s0, 0 # index
	move $s1, $a0 # matrix to read
	matrix_read_loop:
	# get address $t2 (address to store next vector)s
	sll $s2, $s0, 4 # # 16 bit offset per read
	add $s3, $s1, $s2 # add offset $t2 to $t1, store in $t3

	move $a0, $s0
	# save return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal print_row_prompt

	move $a0, $s3 # address to read vector to
	li $a1, 4 # number of integers to read
	jal read_vector

	# restore return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	addi $s0, $s0, 1 # index++
	bne $s0, 4, matrix_read_loop # loop until 4 vector reads finish

	jr $ra

# procedure that reads an int vector from space seperated string of digits
# writes it into $a0, number of elements in vector is $a1
read_vector:
	move $t0, $a0 # write address
	move $t1, $a1 # number of elements in vector

	# read vector string
	li $v0, 8
	la $a0, vector_string
	la $a1, vector_string_length
	syscall # 8 for read string
	
	# convert string ASCII to integer and store in $a0
	la $a0, vector_string # location of string
	move $a1, $t1 # number of elements
	move $a2, $t0 # address to store in
	
	# save return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# convert to ascii and store
	jal convertASCII
	# restore return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# prints 4x4 matrix at $a0
print_matrix:
	li $s0, 0 # index
	move $s1, $a0 # matrix to print
	matrix_print_loop:
		# get address $t2 (address with vector to print)
		sll $s2, $s0, 4 # # 16 bit offset per print
		add $s3, $s1, $s2 # add offset $t2 to $t1, store in $t3
		
		move $a0, $s0
		# save return address
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal print_row_prompt
	
		move $a0, $s3 # address of vector to print
		li $a1, 4 # number of integers to print
		jal print_vector
		
		# restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# print new line
		li $v0, 4
		la $a0, new_line
		syscall
		
		addi $s0, $s0, 1 # index++
		bne $s0, 4, matrix_print_loop # loop until 4 vector reads finish
	
	jr $ra

# procedure to print the vector at $a0, length of vector is $a1
print_vector:
	li $t0, 0 # index
	move $t1, $a0 # array's address
	
	vector_print_loop:
		# get address $t1 with index offset
		sll $t2, $t0, 2 # offset bytes in $t2
		add $t3, $t1, $t2 # add offset $t2 to $t1, store in $t3
		
		# print current int
		li $v0, 1
		lw $a0, 0($t3)
		syscall
		
		# print space
		li $v0, 4
		la $a0, space
		syscall
		
		addi $t0, $t0, 1 # index++
		bne $t0, $a1, vector_print_loop # loop if index has not reached bound
	jr $ra

# converts string $a0 (length $a1) to integer array and stores it in $a2
convertASCII:	
	li $t0, 0 # index
	move $t1, $a1 # bound
	move $t2, $a2 # store address
	move $t3, $a0 # string's address
	ascii_loop:
		# store offsetted array address
		sll $t4, $t0, 2 # array offset bytes in $t4
		add $t5, $t2, $t4 # add offset $t4 to $t2 (array)
		# get offsetted vector_string address
		sll $t4, $t0, 1 # string offset by 2*index for string and space character
		add $t6, $t3, $t4 # add offset $t4 to $t3 (string)
		
		# now $t5 is the offsetted array address and $t6 has offsetted string character
		
		# read ascii representation of the int
		lb $t7, 0($t6) # set $t7 to the current byte in string
		
		# USE MASKING
		# ...00001111 keeps least significant 4 bits
		andi $t7, $t7, 15
		
		# alternative method:
		# SUBTRACT 48 FROM ASCII REPRESENTATION
		# addi $t8, $t8, -48

		# save converted integer ($t7) to current offsetted array address ($t5)
		sw $t7, 0($t5)
		
		addi $t0, $t0, 1 # index++
		bne $t0, $t1, ascii_loop # loop if index has not reached bound
	jr $ra

# print 'Row [i]: ' where i is $a0, the index
print_row_prompt:
	addi $t9, $a0, 1 # row number
	li $v0, 4
	la $a0, row
	syscall
	
	li $v0, 1
	move $a0, $t9
	syscall
	
	li $v0, 4
	la $a0, colon
	syscall
	
	jr $ra


.data
M1: .space 64 # 4x4 integer matrix
M2: .space 64 # 4x4 integer matrix
product: .space 64 # M1 x M2 = product (dot product) 
row: .asciiz "Row "
colon: .asciiz ": "
vector_string: .space 10 # 4 space-seperated ASCII character and \n
vector_string_length: .word 9
new_line: .asciiz "\n"
space: .asciiz " "
