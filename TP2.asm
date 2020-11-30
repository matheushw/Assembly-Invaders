# Trabalho Pratico 2 - TP2 - Opção 2 Jogo
# Organizacao e Arquitetura de Computadores - SSC0902
# Matheus Barcellos de Castro Cunha - 11208238

#$s3 iteracoes tiro inimigo
#$s5 iteracoes
#$s6 posicao do tiro da nave
#$s7 flag do tiro

.data
	frameBuffer: .space 0x80000
	offsetNave: .word 0
	tiroNave: .word 0
	tiroLoopIterations: .word 800
	
	offsetInimigoGeral: .word 508
	offsetInimigos: .word 508, 1532, 2556, 3580
	vidaInimigos: .word 3, 3, 3, 3
	tiroInimigo: .word 0, 0, 0, 0
	iteracaoTiroInimigo: .word 0, 0, 0, 0
	blankSpace: .asciiz " "
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
	j updTiroLoop
updTiroLoop:

#####Inicio de checagem para saber se o inimigo pode disparar#####
	li $a0, 0
	jal checkInimigoAtira
	li $a0, 4
	jal checkInimigoAtira
	li $a0, 8
	jal checkInimigoAtira
	li $a0, 12
	jal checkInimigoAtira
#####Fim de checagem para saber se o inimigo pode disparar#####
	
	#checa se ha tiro amigo no mapa
	bnez $s7, updTiro 
	
#####Inicio checagem se ha tiro inimigo no mapa#####
	lw $t0, tiroInimigo
	bnez $t0, updTiro
	lw $t0, tiroInimigo+4
	bnez $t0, updTiro
	lw $t0, tiroInimigo+8
	bnez $t0, updTiro
	lw $t0, tiroInimigo+12
	bnez $t0, updTiro
#####Fim checagem se ha tiro inimigo no mapa#####
	
	j leituraMM
updTiro:
	sub $s4,$s4,1
	bne $zero, $s4, leituraMM
	
	##Inicio update tiros inimigos##
	li $a0, 0
	jal checkUpdTiroInimigo
	li $a0, 4
	jal checkUpdTiroInimigo
	li $a0, 8
	jal checkUpdTiroInimigo
	li $a0, 12
	jal checkUpdTiroInimigo
	##Fim update tiros inimigos##
		
	beqz $s7, initLoop
	### atualiza tiro da navo, caso haja
	addu $s5, $s5, 1
	jal checkColisao	

	li $t0, 0 
    	la $t1, frameBuffer
    	addu $t1, $t1, $s6 
	sw $t0, ($t1)

	beq $s5, 30, fimMapa
	
	addu $s6, $s6, 4
	
	jal checkColisao
	
	li $t0, -1 
    	addu $t1, $t1, 4
	sw $t0, ($t1)
	
	j initLoop
colidiu:
	lw $t0, vidaInimigos($a0)
	subu $t0, $t0 , 1
	sw $t0, vidaInimigos($a0)
	beqz $t0, inimigoMorto
	j fimMapa   	   	
inimigoMorto:
	li $t0, 0 
    	la $t1, frameBuffer
    	lw $t2, offsetInimigos($a0)
    	    	
    	addu $t1, $t1, $t2 
	sw $t0, ($t1)
	addu $t1, $t1, 124
	sw $t0, ($t1)
	addu $t1, $t1, 4
	sw $t0, ($t1)
	addu $t1, $t1, 128
	sw $t0, ($t1)
	
	sw $t0, offsetInimigos($a0)
	j fimMapa
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

########Início da rotina de checagem e disparo de tiro inimigo########	
checkInimigoAtira:
	lw $t0, vidaInimigos($a0) 
	bnez $t0, checkInimigoAtira2 #Checando se o inimigo $a0 está morto
	jr $ra
checkInimigoAtira2:
	lw $t0, tiroInimigo($a0) 
	beqz $t0, inimigoAtira #Checando se o inimigo $a0 pode atirar
	jr $ra 
inimigoAtira:
	lw $t1, offsetInimigos($a0)
	addu $t0, $t1, 120
	sw $t0, tiroInimigo($a0)
	jr $ra
########Fim da rotina de checagem e disparo de tiro inimigo########

########Início da rotina de atualizacao de um tiro inimigo########
checkUpdTiroInimigo:
	lw $t0, tiroInimigo($a0) 
	bnez $t0, apagaTiroInimigo #Checando se o inimigo $a0 ja atirou
	jr $ra
apagaTiroInimigo:
	li $t1, 0 
    	la $t2, frameBuffer
    	addu $t2, $t2, $t0 
	sw $t1, ($t2)
	j checkUpdTiroInimigo2
checkUpdTiroInimigo2:
	lw $t3, iteracaoTiroInimigo($a0)
	addu $t3, $t3, 1
	bne $t3, 30, updTiroInimigo #Checando se o tiro da nave $a0 chegou no fim do mapa
	j resetarFlagsInimigo
resetarFlagsInimigo:
	li $t4, 0
	sw $t4, tiroInimigo($a0)
	sw $t4, iteracaoTiroInimigo($a0)
	jr $ra
updTiroInimigo:
	li $t1, -1 
	subu $t0, $t0, 4 
    	subu $t2, $t2, 4 
	sw $t1, ($t2)
	sw $t0, tiroInimigo($a0)
	sw $t3, iteracaoTiroInimigo($a0)
	jr $ra
########Fim da rotina de atualizacao de um tiro inimigo########

checkColisao:
	#Checa colisao com nave inimiga 1
	li $a0, 0
	lw $t0, offsetInimigos
	beq $s6, $t0, colidiu
	addu $t0, $t0, 124
	beq $s6, $t0, colidiu
	addu $t0, $t0, 4
	beq $s6, $t0, colidiu
	addu $t0, $t0, 128
	beq $s6, $t0, colidiu
	 
	#Checa colisao com nave inimiga 2
	li $a0, 4
	lw $t0, offsetInimigos($a0)
	beq $s6, $t0, colidiu
	addu $t0, $t0, 124
	beq $s6, $t0, colidiu
	addu $t0, $t0, 4
	beq $s6, $t0, colidiu
	addu $t0, $t0, 128
	beq $s6, $t0, colidiu
	
	#Checa colisao com nave inimiga 3
	li $a0, 8
	lw $t0, offsetInimigos($a0)
	beq $s6, $t0, colidiu
	addu $t0, $t0, 124
	beq $s6, $t0, colidiu
	addu $t0, $t0, 4
	beq $s6, $t0, colidiu
	addu $t0, $t0, 128
	beq $s6, $t0, colidiu
	
	#Checa colisao com nave inimiga 4
	li $a0, 12
	lw $t0, offsetInimigos($a0)
	beq $s6, $t0, colidiu
	addu $t0, $t0, 124
	beq $s6, $t0, colidiu
	addu $t0, $t0, 4
	beq $s6, $t0, colidiu
	addu $t0, $t0, 128
	beq $s6, $t0, colidiu
	
	jr $ra
fim:
	li $v0,10
	syscall
