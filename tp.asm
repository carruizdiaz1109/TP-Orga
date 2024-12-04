; Carolina Ruiz Diaz 111442
; Allison Anampa  111996
; Antonella Hauserman 111906

global	main
extern puts


section	.data
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		db	0x18 ; 24d
	mensajeCodificado db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


	secuenciaImprimibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d

	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	

section	.bss
	secuenciaImprimibleA	resb	32
	secuenciaBinariaB		resb	24
	
section	.text

main:
   
    ;CODIFICACION
    call decodificar 
    
    xor rdi,rdi
    xor rsi,rsi
    xor r9,r9
    xor r8,r8
    xor rdx,rdx
    xor rcx,rcx
    xor rbx,rbx
    xor rax,rax

    ;DECODIFICACION
    call codificar
    mov rdi, mensajeCodificado
    call puts


    mov eax, 60
    xor edi,edi
    syscall


codificar:
    mov rsi, secuenciaBinariaA      ; Puntero a la secuencia binaria
    mov rdi, mensajeCodificado      ; Puntero al buffer de salida
    xor rdx, rdx                    ; Inicializar índice de bytes procesados

procesar_secuencia:
    ; Comprobamos si hemos procesado todos los bytes
    cmp rdx, 0x18                   ; Comparar rdx con el tamaño de la entrada (24 bytes)
    jae fin_codificacion            ; Si rdx >= 24, terminamos

    ; Limpiamos rax para procesar un nuevo bloque
    xor rax, rax

    ; Leemos los 3 bytes en rax
    mov al, byte [rsi]              ; Primer byte
    shl rax, 8                      ; Desplazar 8 bits
    mov al, byte [rsi+1]            ; Segundo byte
    shl rax, 8                      ; Desplazar 8 bits
    mov al, byte [rsi+2]            ; Tercer byte

    ; Dividimos en 4 bloques de 6 bits
    mov rcx, 4                      ; Procesar 4 bloques de 6 bits
    mov rbx, 0x3F                   ; Máscara para extraer los 6 bits (0b111111)

generar_bloque:
    ; Desplazamos rax y extraemos los bits relevantes
    mov r8, rax                     ; Copiar rax a r8
    shr r8, 18                      ; Desplazar 18 bits (primer bloque)
    and r8, rbx                     ; Aplicar la máscara para obtener los 6 bits
    add r8, TablaConversion         ; Mapear índice a carácter en la tabla
    mov r9b, byte [r8]              ; Obtener el carácter correspondiente
    mov byte [rdi], r9b             ; Guardar el carácter en el buffer de salida
    inc rdi                          ; Avanzar el puntero de salida
    shl rax, 6                       ; Preparar para el siguiente bloque
    loop generar_bloque             ; Repetir para los 4 bloques

    add rsi, 3                       ; Avanzar 3 bytes en la entrada
    add rdx, 3                       ; Incrementar el índice de bytes procesados
    jmp procesar_secuencia           ; Procesar el siguiente bloque

fin_codificacion:
    ; Agregamos terminador null al buffer de salida
    mov byte [rdi], 0
    ret

decodificar:

    mov rsi, secuenciaImprimibleB        
    lea rdi, [secuenciaBinariaB]                 
    movzx r15, byte [largoSecuenciaB] 
    xor rcx, rcx                         ; Contador de caracteres procesados
    lea rbx, [TablaConversion]           ; Dirección de la tabla de conversión

decode_loop:
    cmp rcx, r15                         
    jge fin_decodificacion                             

    xor rax, rax                        

    ; Procesamos el primer carácter
    movzx r8, byte [rsi + rcx]
    call buscar_indice
    mov rax, r8                     ; Acumulamos el primer índice

   ; Procesamos el segundo carácter
   movzx r8, byte [rsi + rcx + 1]
   call buscar_indice
   shl rax, 6                      ; Desplazamos 6 bits a la izquierda
    or rax, r8                      ; Acumulamos el segundo indice

   ;  Procesamos el tercer carácter
   movzx r8, byte [rsi + rcx + 2]
   call buscar_indice
    shl rax, 6                ; Desplazamos 6 bits a la izquierda
    or rax, r8                ; Acumulamos el tercer índice

   ; Procesamos el cuarto carácter
   movzx r8, byte [rsi + rcx + 3]
   call buscar_indice
    shl rax, 6                ; Desplazamos 6 bits a la izquierda
    or rax, r8                ; Acumulamos el cuarto índice

   ; Extraemos y guardamos los 3 bytes 
   mov byte [rdi + 2], al             ; Primer byte
   shr rax, 8                    
   mov byte [rdi + 1], al         ; Segundo byte
   shr rax, 8                     
   mov byte [rdi], al         ; Tercer byte

   ; Avanzar punteros
   add rcx, 4                           ; Avanzar 4 caracteres de entrada
   add rdi, 3                           ; Avanzar 3 bytes de salida
   jmp decode_loop                     

fin_decodificacion:
    ret

; Buscamos el indice segun la tabla de conversion
buscar_indice:
    xor r9, r9                           ; Inicializamos el iterador en 0

buscar:
    mov r10b, byte [rbx + r9]             
    cmp r10b, r8b                          ; Comparamos caracter de conversion con el de la secuencia
    je encontrado                       
    inc r9                             
    cmp byte [rbx + r9], 0               
    jne buscar                          

encontrado:
    mov r8, r9                           ; Guardar el índice encontrado en r8
    ret                                  

