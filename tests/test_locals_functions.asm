.text
	beqz $a0, init_end
	lw $a0, 0($a1)
	jal atoi
	la $t0, arg
	sw $v0, 0($t0)
init_end:
	li $t0, 5
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal test
	addi $sp, $sp, 4
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	la $t0, t
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
	la $t0, t
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal print
	addi $sp, $sp, 4
	li $v0, 10
	syscall
atoi:
	move $t0, $a0
	li $t1, 0
	li $t3, 10
	li $t4, 48
	li $t5, 57
atoi_loop:
	lbu $t2, 0($t0)
	beq $t2, $zero, atoi_end
	blt $t2, $t4, atoi_error
	bgt $t2, $t5, atoi_error
	addi $t2, $t2, -48
	mul $t1, $t1, $t3
	add $t1, $t1, $t2
	addi $t0, $t0, 1
	b atoi_loop
atoi_error:
	li $v0, 10
	syscall
atoi_end:
	move $v0, $t1
	jr $ra
#print
print:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	subi $sp, $sp, 4
	move $fp, $sp
	addi $fp, $fp, 8
	lw $a0, 4($fp)
	li $v0, 11
	syscall
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $fp, 0($sp)
	jr $ra
#print_int
print_int:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	subi $sp, $sp, 4
	move $fp, $sp
	addi $fp, $fp, 8
	lw $a0, 4($fp)
	li $v0, 1
	syscall
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $fp, 0($sp)
	jr $ra
#power
power:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	subi $sp, $sp, 4
	move $fp, $sp
	addi $fp, $fp, 8
	lw $s0, 8($fp)
	lw $s1, 4($fp)
	li $t0, 1
	b power_loop_guard
power_loop_code:
	mul $t0, $t0, $s1
	subi $s0, $s0, 1
power_loop_guard:
	bgtz $s0, power_loop_code
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $fp, 0($sp)
	jr $ra
test:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	subi $sp, $sp, 4
	move $fp, $sp
	addi $fp, $fp, 8
	subi $sp, $sp, 12
	li $t0, 92
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	move $t0, $fp
	addi $t0, $t0, -8
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
	lw $t0, -8($fp)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal print
	addi $sp, $sp, 4
	li $t0, 47
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	move $t0, $fp
	addi $t0, $t0, -12
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
	lw $t0, -12($fp)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal print
	addi $sp, $sp, 4
	li $t0, 10
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	move $t0, $fp
	addi $t0, $t0, -16
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
	lw $t0, -16($fp)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal print
	addi $sp, $sp, 4
	lw $t0, -8($fp)
	addi $sp, $sp, 12
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $fp, 0($sp)
	jr $ra
	addi $sp, $sp, 12
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $fp, 0($sp)
	jr $ra
.data
t:
	.word 0
arg:
	.word 0
