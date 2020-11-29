# Trabalho Pratico 2 - TP2 - Opção 2 Jogo
# Organizacao e Arquitetura de Computadores - SSC0902
# Matheus Barcellos de Castro Cunha - 11208238

#$s5 iteracoes
#$s6 posicao do tiro da nave
#$s7 flag do tiro

.data
	frameBuffer: .space 0x80000
	offsetNave: .word 0
	tiroNave: .word 0
	tiroLoopIterations: .word 500
	
	offsetInimigoGeral: .word 508
	offsetInimigo1: .word 508
	offsetInimigo2: .word 1532
	offsetInimigo3: .word 2556
	offsetInimigo4: .word 3580
		
	blankSpace: .asciiz " "
	Vetor: .word 15, 31, 63, 127, 255, 511, 1023, 2047, 4097, 65536, 0 
	End: .word 0
	Ini: .word 0
.text
	.glob main
	
inicializaJogo:
	jal printarNave
	jal printarInimigo
	jal printarInimigo
	jal printarInimigo
	jal printarInimigo
	li $s5, 0
	li $s6, 0
	li $s7, 0

initLoop:
	lw $s4, tiroLoopIterations

updTiroLoop:
	beqz $s7, leituraMM
	sub $s4,$s4,1
	j updTiro
updTiro:
	bne $zero, $s4, leituraMM
	
	addu $s5, $s5, 1
	
	li $t0, 0 
    	la $t1, frameBuffer
    	addu $t1, $t1, $s6 
	sw $t0, ($t1)
	
	beq $s5, 30, fimMapa
	
	addu $s6, $s6, 4
	
	li $t0, -1 
    	addu $t1, $t1, 4
	sw $t0, ($t1)
	
	j initLoop
	
checkColisao:

fimMapa:
	li $s5, 0
	li $s6, 0	
	li $s7, 0
	j initLoop

leituraMM:
	lw $t0, 0xffff0000 #Carrega espaço de memória que indica chegada de input
	andi $t0, $t0, 0x00000001 #Isolando bit pra obter a flag
	beqz $t0, updTiroLoop #Caso não tenha chego nada
	
identificaTecla:
	lbu $a0, 0xffff0004 #Lê memória que guarda o input do teclado
	move $s0, $a0 
	li $t1,'x' #Parar a execucao
	beq $a0, $t1, fim
	li $t1,'z' #Mover para baixo
	beq $a0, $t1, naveParaBaixo
	li $t1,'a' #Mover para cima
	beq $a0, $t1, naveParaCima
	li $t1,' ' #Atirar
	beq $a0, $t1, atirar
	j updTiroLoop
		
naveParaBaixo:
	lw $a0, offsetNave
	BEQ $a0, 3712, updTiroLoop
	jal apagarNave
	addu $a0, $a0, 128
	sw $a0, offsetNave
	jal printarNave
	j updTiroLoop

naveParaCima:
	lw $a0, offsetNave
	BEQ $a0, 0, updTiroLoop
	jal apagarNave
	subu $a0, $a0, 128
	sw $a0, offsetNave
	jal printarNave
	j updTiroLoop

printarNave:
	li $t0, -1 
    	la $t1, frameBuffer
    	lw $t2, offsetNave
    	
    	addu $t1, $t1, $t2 
	sw $t0, ($t1)
	
	addu $t1, $t1, 128
	sw $t0, ($t1)
	
	addu $t1, $t1, 4
	sw $t0, ($t1)
	
	addu $t1, $t1, 124
	sw $t0, ($t1)
	
	jr $ra
	
apagarNave:
	li $t0, 0 
    	la $t1, frameBuffer
    	lw $t2, offsetNave
    	
    	addu $t1, $t1, $t2 
	sw $t0, ($t1)
	
	addu $t1, $t1, 128
	sw $t0, ($t1)
	
	addu $t1, $t1, 4
	sw $t0, ($t1)
	
	addu $t1, $t1, 124
	sw $t0, ($t1)
	
	jr $ra
	
printarInimigo:
	li $t0, 0xff0000 
    	la $t1, frameBuffer
    	lw $t2, offsetInimigoGeral
    	
    	addu $t1, $t1, $t2 
	sw $t0, ($t1)
	
	addu $t1, $t1, 128
	sw $t0, ($t1)
	
	subu $t1, $t1, 4
	sw $t0, ($t1)
	
	addu $t1, $t1, 132
	sw $t0, ($t1)
	
	lw $t2, offsetInimigoGeral
	addu $t2, $t2, 1024
	sw $t2, offsetInimigoGeral
	
	jr $ra

atirar:
	bnez $s7, leituraMM
	li $s5, 0	
	li $s7, 1
	lw $s6, offsetNave
	addu $s6, $s6, 136  
	li $s4, 1
	j updTiroLoop

fim:
	li $v0,10
	syscall
