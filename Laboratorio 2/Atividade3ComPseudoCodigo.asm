#pseudo código
#if i == j(f = g+h)
#else f = g - h

beq x22, x23, cond #if i==j, cond
#else
sub x19, x20, x21 #f = g-h

fim:
	halt

cond:
	add x19, x20, x21 #f = g+h
	jal x0, fim
	
