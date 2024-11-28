global main
extern printf

; PILA
%macro ALINEAR_PILA 1
    push rbp
    mov rbp, rsp
    sub rsp, %1
%endmacro

%macro DESALINEAR_PILA 0
    leave
    ret
%endmacro

; Macro para recorrer palabra y buscar posiciones en la tabla
%macro RECORRER_PALABRA 0
    mov dword [iterador], 0        ; Inicializar iterador
iterar_palabra:
    mov ecx, [iterador]            ; Índice actual
    cmp ecx, 4                     ; Limitar al tamaño de 4 caracteres
    jae fin_recorrer               ; Salir si se excede el límite

    mov al, [palabra + ecx]        ; Cargar carácter actual
    cmp al, 0                      ; ¿Es el fin de la cadena?
    je fin_recorrer

    ; Buscar posición
    lea rsi, [TablaConversion]     ; Dirección de la tabla
    push rcx                       ; Guardar registro temporalmente
    call buscar_posicion           ; AL = posición encontrada
    pop rcx                        ; Restaurar índice
    mov [posiciones + ecx], al     ; Guardar la posición encontrada

    ; Incrementar iterador
    add dword [iterador], 1
    jmp iterar_palabra
fin_recorrer:
%endmacro

; Macro para mostrar posiciones encontradas (en binario)
%macro MOSTRAR_POSICIONES 0
    mov dword [iterador], 0        ; Reiniciar iterador
mostrar_bucle:
    mov ecx, [iterador]            ; Índice actual
    cmp ecx, 4                     ; Limitar al tamaño de 4 caracteres
    jae fin_mostrar                ; Salir si se excede el límite

    mov al, [posiciones + ecx]     ; Cargar posición actual
    cmp al, -1                     ; ¿Fin de posiciones?
    je fin_mostrar

    ; Convertir posición a binario
    movzx rax, al                  ; Extender al a 64 bits
    lea rdi, [buffer_binario]      ; Dirección del buffer para el binario
    call convertir_a_binario       ; Llamar a la función de conversión

    ; Imprimir el binario
    mov rdi, mloop_bin             ; Formato para imprimir el binario
    mov rsi, buffer_binario        ; Pasar el binario convertido
    xor rax, rax                   ; Preparar para printf
    call printf

    ; Incrementar iterador
    add dword [iterador], 1
    jmp mostrar_bucle
fin_mostrar:
%endmacro

; Función para buscar la posición de un carácter en la tabla
buscar_posicion:
    xor rcx, rcx                  ; Inicializar índice
buscar_bucle:
    mov dl, [rsi + rcx]           ; Cargar carácter de la tabla
    cmp dl, 0                     ; ¿Fin de tabla?
    je no_encontrado

    cmp dl, al                    ; ¿Coincide el carácter?
    je encontrado

    inc rcx                       ; Incrementar índice
    jmp buscar_bucle

no_encontrado:
    mov al, -1                    ; Retornar -1 si no se encuentra
    ret

encontrado:
    mov al, cl                    ; Retornar índice encontrado en AL
    ret

; Función para convertir un número a binario
convertir_a_binario:
    mov r8, 8                     ; Número de bits
    lea rdi, [buffer_binario + 8] ; Apuntar al final del buffer
    mov byte [rdi], 0             ; Terminar la cadena con un 0
convertir_bucle:
    dec rdi                       ; Retroceder un carácter en el buffer
    mov r9, rax                   ; Copiar el valor de rax
    and r9, 1                     ; Obtener el bit menos significativo
    add r9b, '0'                  ; Convertir a carácter ASCII ('0' o '1')
    mov [rdi], r9b                ; Almacenar en el buffer
    shr rax, 1                    ; Desplazar rax un bit a la derecha
    dec r8                        ; Decrementar contador de bits
    jnz convertir_bucle           ; Repetir para los 8 bits
    ret

section .text
main:
    ALINEAR_PILA 16

    ; Modificar palabra reemplazando letras por posiciones
    RECORRER_PALABRA

    ; Mostrar posiciones encontradas en binario
    MOSTRAR_POSICIONES

    DESALINEAR_PILA

section .data
    palabra db "AlEx", 0           ; Palabra de hasta 4 caracteres
    mloop_bin db "Binario: %s", 10, 0
    TablaConversion db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0

section .bss
    iterador resd 1
    posiciones resb 4              ; Espacio reducido a 4 bytes
    buffer_binario resb 9          ; Buffer para 8 bits + terminador nulo

