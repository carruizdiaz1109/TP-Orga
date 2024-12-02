global main
extern imprimir_secuencia ; Declarar función de C para imprimir

%macro ALINEAR_PILA 1
    push rbp
    mov rbp, rsp
    sub rsp, %1
%endmacro

%macro DESALINEAR_PILA 0
    leave
    ret
%endmacro

%macro DECODIFICADOR 0
    xor rdi, rdi                        ; Inicializa el contador (rdi = 0)
    lea rsi, [secuenciaImprimibleB]     ; Apunta al inicio de secuenciaImprimibleB
    lea rdx, [secuenciaBinariaB]        ; Apunta al inicio de secuenciaBinariaB
    movzx rcx, byte [largoSecuenciaB]   ; Carga largoSecuenciaB en rcx

    procesar_bloques:
        cmp rdi, rcx                    ; ¿Hemos procesado todos los bloques?
        je fin_decodificacion           ; Salta si el contador alcanza el límite

        ; Cargar 4 caracteres y obtener sus índices
        mov r9, [rsi]                   ; Cargar primer carácter en r9
        call obtener_indice             ; Obtener el índice en TablaConversion
        shl rax, 6                      ; Desplazar 6 bits a la izquierda (para el primer carácter)
        
        ; Depuración: Imprimir el valor de rax después del primer desplazamiento
        mov rdi, rax
        call imprimir_secuencia
        
        mov r10, [rsi + 1]              ; Cargar segundo carácter en r10
        call obtener_indice
        or rax, rbx                     ; Agregar al bloque (OR con el índice del segundo carácter)
        shl rax, 6                      ; Desplazar 6 bits a la izquierda
        
        ; Depuración: Imprimir el valor de rax después del segundo desplazamiento
        mov rdi, rax
        call imprimir_secuencia
        
        mov r11, [rsi + 2]              ; Cargar tercer carácter en r11
        call obtener_indice
        or rax, rbx                     ; Agregar al bloque (OR con el índice del tercer carácter)
        shl rax, 6                      ; Desplazar 6 bits a la izquierda
        
        ; Depuración: Imprimir el valor de rax después del tercer desplazamiento
        mov rdi, rax
        call imprimir_secuencia
        
        mov r12, [rsi + 3]              ; Cargar cuarto carácter en r12
        call obtener_indice
        or rax, rbx                     ; Agregar al bloque (OR con el índice del cuarto carácter)

        ; Depuración: Imprimir el valor de rax después de agregar el cuarto carácter
        mov rdi, rax
        call imprimir_secuencia
        
        ; Asegurarse de que estamos almacenando los 3 bytes correctamente
        mov byte [rdx], al              ; Guardar el primer byte
        shr rax, 8
        mov byte [rdx + 1], al          ; Guardar el segundo byte
        shr rax, 8
        mov byte [rdx + 2], al          ; Guardar el tercer byte

        ; Avanzar punteros y contador
        add rsi, 4                      ; Avanzar 4 caracteres
        add rdx, 3                      ; Avanzar 3 bytes
        add rdi, 4                      ; Incrementar contador

        ; Verificar si rsi se sale del límite
        cmp rsi, secuenciaImprimibleB + largoSecuenciaB ; Compara con el límite
        ja fin_decodificacion            ; Si se sale, terminar la decodificación

        jmp procesar_bloques            ; Repetir el proceso para el siguiente bloque

    fin_decodificacion:
%endmacro

obtener_indice:
    push rdi                           ; Guardar registros que se modificarán
    push rsi

    lea rsi, [TablaConversion]         ; Cargar la tabla de conversión
    xor rdi, rdi                       ; Inicializar índice

.buscar_caracter:
    cmp byte [rsi + rdi], al           ; Comparar carácter actual con `al`
    je .encontrado                     ; Si coincide, salir del bucle
    inc rdi                            ; Incrementar el índice
    cmp rdi, 64                        ; ¿Fuera de rango de la tabla?
    je .error                          ; Si es así, salir con error
    jmp .buscar_caracter               ; Continuar buscando

.encontrado:
    mov rbx, rdi                       ; Guardar el índice encontrado en rbx
    
    ; Depuración: Imprimir el índice encontrado
    mov rdi, rbx                       ; Pasar el índice a rdi para la impresión
    call imprimir_secuencia            ; Imprimir el índice
    
    pop rsi                            ; Restaurar registros
    pop rdi
    ret

.error:
    ; Manejo de errores aquí si es necesario
    mov rbx, 0                          ; Retorna 0 en caso de error
    pop rsi
    pop rdi
    ret

imprimir_secuencia:
    ; Aquí puedes implementar la función de impresión (ejemplo con printf o similar)
    ret

section .text

main:
    ALINEAR_PILA 16                     ; Configurar el marco de pila y reservar espacio
    DECODIFICADOR
    lea rdi, [secuenciaBinariaB]        ; Cargar la dirección de secuenciaBinariaB en rdi
    call imprimir_secuencia             ; Llamar a la función de C para imprimir la secuencia
    DESALINEAR_PILA                     ; Restaurar el marco de pila

section .data
    secuenciaImprimibleB db "vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
    largoSecuenciaB      db 0x20 ; 32d
    TablaConversion      db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

section .bss
    secuenciaBinariaB    resb 24 ; Reservar espacio para la secuencia binaria

