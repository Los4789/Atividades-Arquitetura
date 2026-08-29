addi x14, x0, 0x34     # x14 = endereço de a1
addi x13, x0, 3      # x13 = contador do 'for'

loop_inicio:
    beq x13, x0, fim     #if x13 == 0, fim

    lw x10, 0(x14)       # Carrega a
    lw x11, 4(x14)       # Carrega b

    add x12, x0, x10     # m = a

    bge x12, x11, pula   # if m >= b, pula a adição
    add x12, x11, x10    # m = a + b

pula:
    sw x12, 8(x14)       # guarda m

    addi x14, x14, 12    # Avança o ponteiro em 12 (4*3)
    addi x13, x13, -1    # x13--;
   	jal  x0, loop_inicio # Volta pro inicio

fim:
    halt

#Variaveis
a1: .word 6
b1: .word 15
m1: .word 0
a2: .word 14
b2: .word 7
m2: .word 0
a3: .word 25
b3: .word 12
m3: .word 0
