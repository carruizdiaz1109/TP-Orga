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

        ; Procesar 4 caracteres a bloques de 6 bits
        xor rax, rax                    ; Limpiar rax antes de reconstruir
        mov al, byte [rsi]              ; Leer el primer carácter
        call obtener_indice             ; Obtener el índice en TablaConversion
        shl rax, 6                      ; Desplazar 6 bits a la izquierda

        mov bl, byte [rsi + 1]          ; Leer el segundo carácter
        call obtener_indice
        or al, bl                       ; Agregar al bloque

        shl rax, 6                      ; Desplazar 6 bits a la izquierda
        mov bl, byte [rsi + 2]          ; Leer el tercer carácter
        call obtener_indice
        or al, bl

        shl rax, 6                      ; Desplazar 6 bits a la izquierda
        mov bl, byte [rsi + 3]          ; Leer el cuarto carácter
        call obtener_indice
        or al, bl

        ; Dividir el bloque de 24 bits en 3 bytes
        mov byte [rdx], al              ; Guardar el primer byte
        shr rax, 8
        mov byte [rdx + 1], al          ; Guardar el segundo byte
        shr rax, 8
        mov byte [rdx + 2], al          ; Guardar el tercer byte

        ; Avanzar punteros y contador
        add rsi, 4                      ; Avanzar 4 caracteres
        add rdx, 3                      ; Avanzar 3 bytes
        add rdi, 4                      ; Incrementar contador

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
    mov al, dil                        ; Guardar el índice en `al`
    pop rsi                            ; Restaurar registros
    pop rdi
    ret

.error:
    ; Manejo de errores aquí si es necesario
    mov al, 0                          ; Retorna 0 en caso de error
    pop rsi
    pop rdi
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
    secuenciaBinariaB    resb 24
