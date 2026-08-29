addi x14, x0, 60
addi x13, x0, 3

loop_inicio:
    beq x13, x0, fim #if x13 == 0, fim

    lw x10, 0(x14) #a vai pra x10
    lw x11, 4(x14) #b vai pra x11
	add x12, x0, x0 #zera x12

    bge x12, x11, pula_else #if b>=m, pula_else
    add x12, x11, x10 #if b<m, m=a+b

conclusao:
    sw x12, 8(x14) #guarda m

    addi x14, x14, 12 #incrementa ponteiro
    addi x13, x13, -1 #x13--
    jal  x0, loop_inicio

fim:
    halt

pula_else:
    sub x12, x11, x10
    jal x0, conclusao

# Variaveis
a1: .word 6
b1: .word 15
m1: .word 0
a2: .word 14
b2: .word 7
m2: .word 0
a3: .word 25
b3: .word 12
m3: .word 0
