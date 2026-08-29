add x11, x0, x0 #zerando reg 11

printchar:
	lb x10, 0x01c(x11) #x10 recebe char
	beq x10, x0, fim #if x10==0, fim
	sb x10, 1024(x0)#saida recebe x10
	addi x11, x11, 1 #x11 incrementa
	jal x0, printchar

fim:
	halt

str1: .string "Hello World"

