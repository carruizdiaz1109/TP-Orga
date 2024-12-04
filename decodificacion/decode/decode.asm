
global	main

section .data
    secuenciaImprimibleA db "vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU" 
    largoSecuenciaImprimibleA db 32                             
    TablaConversion db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0 

section .bss
    secuenciaBinariaA resb 24 

section .text

main:
    mov rsi, secuenciaImprimibleA        
    lea rdi, [secuenciaBinariaA]                 
    movzx r15, byte [largoSecuenciaImprimibleA] 
    xor rcx, rcx                         ; Contador de caracteres procesados
    lea rbx, [TablaConversion]           ; Dirección de la tabla de conversión

decode_loop:
    cmp rcx, r15                         
    jge fin                             

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
   mov byte [rdi ], al         ; Tercer byte

   ; Avanzar punteros
   add rcx, 4                           ; Avanzar 4 caracteres de entrada
   add rdi, 3                           ; Avanzar 3 bytes de salida
   jmp decode_loop                     

fin:
    ; Salir del programa
    mov eax, 60                          
    xor edi, edi                         
    syscall

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

