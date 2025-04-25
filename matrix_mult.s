# Registros usados, 
# a0 - puntero a matriz A
# a1 - puntero a matriz B
# a2 - puntero a matriz C (resultado)
# t0  - índice i para recorrer filas
# t1  - índice j para recorrer columnas
# t2  - índice k para multiplicación
# t3 - valor actual de A[i][k]
# t4 - valor actual de B[k][j]
# t5 - acumulador para C[i][j]
# t6 - registro temporal para cálculos
# s1  - dirección calculada para A[i][k]
# s2 - dirección calculada para B[k][j]
# s3 - dimensión de la matriz (3 para 3x3)
# s4 - tamaño de palabra (4 bytes)
# s5 - tamaño en bytes de una fila completa
# s6 - dirección calculada para C[i][j]

.data
# inicialización de matrices, cada casilla es un word
matrix_A: .word 2, 3, 5, 5, 8, 6, 9, 2, 4 
matrix_B: .word 2, 3, 5, 7, 8, 9, 1, 6, 2 
matrix_C: .word 0, 0, 0, 0, 0, 0, 0, 0, 0 
msg_result: .string "\nMatriz resultante C:\n"
.text
main:
	# guardamos las direcciones de memoria en donde inicia cada matriz
	la a0, matrix_A  
	la a1, matrix_B   
	la a2, matrix_C      
	
	# configuramos valores constantes que necesitamos
	li s3, 3               # matrices 3x3
	li s4, 4               # cada número ocupa 4 bytes (un word)
	mul s5, s3, s4         # bytes por fila = 3 palabras * 4 bytes = 12 bytes
	
	# C[i][j] = A[i][0]*B[0][j] + A[i][1]*B[1][j] + A[i][2]*B[2][j]
	li t0, 0               # inicializar el indice que itera por renglones
loop_i:
	li t1, 0               # inicializar indice de columnas
loop_j:
	li t5, 0               # inicializamos acumulador para este elemento C[i][j]
	li t2, 0               # iterador que cambia de columna en A y renglon en B
loop_k:
	# calcular dirección de renglón
	mul t6, t0, s5         # i * tam_fila = offset de fila (cambia con i)
	mul s1, t2, s4         # k * tam_palabra = offset de columna (cambia con k)
	add s1, s1, t6         # (i * tam_fila) + (k * tam_palabra) = offset de casilla
	add s1, s1, a0         # dirección base A + offset = dirección de memoria de casilla
	# calculamos dirección de B[k][j]
	mul t6, t2, s5         # k * tam_fila = offset de fila (cambia con k)
	mul s2, t1, s4         # j * tam_palabra = offset de columna (cambia con j)
	add s2, s2, t6         # (k * tam_fila) + (j * tam_palabra) = offset de casilla
	add s2, s2, a1         # dirección base B + offset = dirección de memoria de la casilla
	
	# cargar valores a multiplicar usando los punteros previamente obtenidos
	lw t3, 0(s1)          
	lw t4, 0(s2)          
	
	# realizamos multiplicación y acumulamos
	mul t6, t3, t4         # A[i][k] * B[k][j]
	add t5, t5, t6         # acumulamos en C[i][j]
	
	# esto se repite 2 veces mas para multiplicar todos los elemenots de un renglon por todos los de una columna
	addi t2, t2, 1         # se incrementa el iterador
	blt t2, s3, loop_k     # si k < 3, se repite el bucle
	
	# ya terminamos de calcular C[i][j], guardamos el resultado
	mul t6, t0, s5         # i * tam_fila = offset de renglon
	mul s6, t1, s4         # j * tam_palabra = offset de columna
	add s6, s6, t6         # (i * tam_fila) + (j * tam_palabra) = offset de casilla
	add s6, s6, a2         # dirección base C + offset = dirección de memoria de la casilla
	
	# guardamos valor calculado en memoria
	sw t5, 0(s6)        
	
	# avanzamos a siguiente columna
	addi t1, t1, 1         # j += 1
	blt t1, s3, loop_j     # si j < 3, procesamos siguiente columna
	
	# avanzamos a siguiente fila
	addi t0, t0, 1         # i += 1
	blt t0, s3, loop_i     # si i < 3, procesamos siguiente fila
	# fin del algoritmo
    # parte de impresión, ya no importa esta part
    li s7, 10              # código para newline
    li s8, 32              # código para espacio
	
	la a0, msg_result               
	li a7, 4                    
	ecall
	
	li t0, 0                # inicializar iterador para ir por cada fila
	
print_loop_i:
	li t1, 0                  
	
print_loop_j:
	# calcular dirección de C[i][j], es lo mismo que hice arriba
	mul t6, t0, s5    
	mul s6, t1, s4  
	add s6, s6, t6      
	add s6, s6, a2    
	
	lw a0, 0(s6)          # carga el valor en a0
	li a7, 1              # código para PrintInt
	ecall
	
	mv a0, s8             # imprimir espacio
	li a7, 11
	ecall
	
	addi t1, t1, 1
	blt t1, s3, print_loop_j
	# termina de imprimir el renglon y pongon un enter
	mv a0, s7             # imprimir nueva línea
	li a7, 11
	ecall
	
	addi t0, t0, 1
	blt t0, s3, print_loop_i
	
	li a7, 10             # código para salir
	ecall
