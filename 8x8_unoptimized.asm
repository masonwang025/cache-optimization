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
    move $t2, $a0 # product
    move $t3, $a1 # M1
    move $t4, $a2 # M2
    
    li $t1, 8 # $t1 = size (row size/loop end) 
    li $s0, 0 # i = 0; initialize 1st for loop
    L1: li $s1, 0 # j = 0; restart 2nd for loop
        L2: li $s2, 0 # k = 0; restart 3rd for loop
        sll $t2, $s0, 3 # $t2 = i * 8 (size of row of c)
        addu $t2, $t2, $s1 # $t2 = i * size(row) + j
        sll $t2, $t2, 2 # $t2 = byte offset of [i][j]
        addu $t2, $a0, $t2 # $t2 = byte address of c[i][j]
        lw $t4, 0($t2) # $t4 = 8 bytes of c[i][j]
        L3: sll $t0, $s2, 3 # $t0 = k * 8 (size of row of b)
            addu $t0, $t0, $s1 # $t0 = k * size(row) + j
            sll $t0, $t0, 2 # $t0 = byte offset of [k][j]
            addu $t0, $a2, $t0 # $t0 = byte address of b[k][j]
            lw $t5, 0($t0) # $t5 = 8 bytes of b[k][j]
            sll $t0, $s0, 3 # $t0 = i * 8 (size of row of a)
            addu $t0, $t0, $s2 # $t0 = i * size(row) + k
            sll $t0, $t0, 2 # $t0 = byte offset of [i][k]
            addu $t0, $a1, $t0 # $t0 = byte address of a[i][k]
            lw $t6, 0($t0) # $t6 = 8 bytes of a[i][k]
            mul $t5, $t6, $t5 # $t5 = a[i][k] * b[k][j]
            add $t4, $t4, $t5 # t4 = c[i][j] + a[i][k] * b[k][j]
            addiu $s2, $s2, 1 # $k = k + 1
            bne $s2, $t1, L3 # if (k != 8) go to L3
            sw $t4, 0($t2) # c[i][j] = $t4
            addiu $s1, $s1, 1 # $j = j + 1
            bne $s1, $t1, L2 # if (j != 8) go to L2
            addiu $s0, $s0, 1 # $i = i + 1
            bne $s0, $t1, L1 # if (i != 8) go to L1
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
