addi x11, x0, 1
sb x11, 1029(x0) #Inicia aceso

espera:
	lb x10, 1026(x0)
	andi x10, x10, 0x1 #bitwise and
	beq x10, x0, espera

soltou:
	lb x10, 1026(x0) #le denovo
	andi x10, x10, 0x1
	bne x10, x0, soltou #se ainda aperta
	slli x11, x11, 1
	sb x11, 1029(x0)
	addi x12, x0, 128
	beq x11, x12, fim
	jal x0, espera

fim:
	halt
