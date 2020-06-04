.text
start:
	# DEFINED INPUT
	la $a0, M1 # matrix 1
	la $a0, M2 # matrix 2
	
	# matrix multiply
	la $a2, M2
	la $a1, M1
	la $a0, product
	# M1 * M2 -> product
	jal matrix_multiply
	
	# print output
	la $a0, product
	jal print_matrix
	
	# exit
	li $v0, 10
	syscall

# a1 * a2 -> a0
# 8x8 matrices
matrix_multiply:
	# written to reflect book's C code as closely as possible
	move $s0, $a0 # product
	move $s1, $a1 # M1
	move $s2, $a2 # M2
	
	li $s3, 0 # si = 0; initialize 1st for loop
	L1: li $s4, 0 # sj = 0; restart 2nd for loop
		L2: li $s5, 0 # sk = 0; restart 3rd for loop
			L3: # inner loop, do_block
				# save registers and jump to do_block
				addi $sp, $sp, -32
				sw $ra, 28($sp) # return address
				sw $s0, 24($sp) # product address
				sw $s1, 24($sp) # M1 address
				sw $s2, 20($sp) # M2 address
				sw $s3, 8($sp) # si
				sw $s4, 4($sp) # sj
				sw $s5, 0($sp) # sk
				
				# do_block(si, sj, sk, A, B, C);
				# where A is M1, B is M2, and C is product
				move $a0, $s3 # si
				move $a1, $s4 # sj
				move $a2, $s5 # sk
				# A, B, C will be in saved registers s3, s4, s5
				jal do_block
				
				# restore registers
				lw $s5, 0($sp) # sk
				lw $s4, 4($sp) # sj
				lw $s3, 8($sp) # si
				lw $s2, 20($sp) # M2 address
				lw $s1, 24($sp) # M1 address
				lw $s0, 24($sp) # product address
				lw $ra, 28($sp) # return address
				addi $sp, $sp, 32
				
				addi $s5, $s5, 4 # sk += BLOCKSIZE
				bne $s5, 8, L3 # if (sk != 8) go to L3
				addi $s4, $s4, 4 # sj += BLOCKSIZE
				bne $s4, 8, L2 # if (sj != 8) go to L2
				addi $s3, $s3, 4 # si += BLOCKSIZE
				bne $s3, 8, L1 # if (si != 8) go to L1
	jr $ra

do_block:
	# values for conditional statements in loops to test against
	# calculate only once prior to loops to save time and register usage
	# si, sj, and sk in $a0, $a1, $a2 respectively
	addi $t0, $a0, 4 # i < si + BLOCKSIZE, so stop value is (si + BLOCKSIZE) = ($a0 + 4) => $t0
	addi $t1, $a1, 4 # j < sj + BLOCKSIZE, so stop value is (sj + BLOCKSIZE) = ($a1 + 4) => $t1
	addi $t2, $a2, 4 # k < sk + BLOCKSIZE, so stop value is (sk + BLOCKSIZE) = ($a2 + 4) => $t2
	
	# preserve si, sj, sk for loop restart
	move $s5, $a0 # si
	move $s6, $a1 # sj
	move $s7, $a2 # sk
	
	# i, j, k will be in $s0, $s1, $s2 respectively
	move $s0, $s5 # i = si
	blockL1: 
		move $s1, $s6 # j = sj, restart second loop
		blockL2:
			move $s2, $s7 # k = sk, restart third loop
			blockL3:
				# print in format: "si sj sk\n"
				li $v0, 1
				move $a0, $s0
				syscall # print i
				
				# print space
				li $v0, 4
				la $a0, space
				syscall
				
				li $v0, 1
				move $a0, $s1
				syscall # print j
				
				# print space
				li $v0, 4
				la $a0, space
				syscall
				
				li $v0, 1
				move $a0, $s2
				syscall # print k
				
				# print new line
				li $v0, 4
				la $a0, new_line
				syscall
			
			
			# increment then test against the pre-calculated stop values
			addi $s2, $s2, 1 # ++k
			bne $s2, $t2, blockL3 # (if k != (sk + BLOCKSIZE)) go to L3
			
			# print new line
			li $v0, 4
			la $a0, new_line
			syscall
			
			addi $s1, $s1, 1 # ++j
			bne $s1, $t1, blockL2 # (if j != (sj + BLOCKSIZE)) go to L2
			addi $s0, $s0, 1 # ++i
			bne $s0, $t0, blockL1 # (if i != (si + BLOCKSIZE)) go to L1
	
	jr $ra

# prints 8x8 matrix at $a0
print_matrix:
	li $s0, 0 # index
	move $s1, $a0 # matrix to print
	matrix_print_loop:
		# get address $t2 (address with vector to print)
		sll $s2, $s0, 5 # 32 bit offset per print
		add $s3, $s1, $s2 # add offset $t2 to $t1, store in $t3
		
		move $a0, $s0
		# save return address
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal print_row_prompt
	
		move $a0, $s3 # address of vector to print
		li $a1, 8 # number of integers to print
		jal print_vector
		
		# restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# print new line
		li $v0, 4
		la $a0, new_line
		syscall
		
		addi $s0, $s0, 1 # index++
		bne $s0, 8, matrix_print_loop # loop until 4 vector reads finish
	
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
# two defined 8 by 8 matrices
M1: .word 1, 2, 1, 1, 0, 0, 1, 2,
		  0, 4, 0, 1, 7, 4, 3, 3,
		  2, 3, 4, 1, 6, 1, 9, 1,
		  1, 9, 7, 0, 7, 8, 1, 2,
		  2, 1, 8, 6, 8, 2, 1, 1,
		  6, 1, 8, 1, 0, 2, 1, 7,
		  1, 2, 9, 1, 2, 7, 1, 9,
		  6, 1, 1, 1, 6, 2, 2, 1
		  
M2: .word 8, 8, 9, 1, 7, 1, 2, 3,
		  1, 3, 0, 0, 1, 2, 4, 5,
		  5, 2, 5, 7, 2, 8, 5, 7,
		  3, 3, 0, 5, 2, 0, 0, 0,
		  2, 0, 0, 5, 9, 7, 8, 8,
		  1, 9, 7, 8, 3, 3, 0, 1,
		  2, 3, 5, 1, 6, 6, 2, 3,
		  7, 0, 1, 1, 2, 4, 6, 4						

product: .space 256 # M1 x M2 = product (dot product) 
row: .asciiz "Row "
colon: .asciiz ": "
new_line: .asciiz "\n"
space: .asciiz " "
