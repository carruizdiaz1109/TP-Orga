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

; Macro para mostrar el valor de la tabla correspondiente al índice
%macro MOSTRAR_INDICE 0
    ; Cargar el primer byte de la secuencia binaria
    movzx rax, byte [secuenciaBinariaA]    ; Cargar el valor en RAX y extenderlo

    ; Usar el valor como índice para acceder a la tabla
    lea rbx, [tabla]                       ; Cargar la dirección base de la tabla en RBX
    movzx rcx, byte [rbx + rax]            ; Obtener el carácter correspondiente

    ; Preparar la llamada a printf
    lea rdi, [formato]                     ; Cargar el formato
    mov rsi, rcx                           ; Pasar el carácter como argumento
    xor rax, rax                           ; Limpiar RAX para printf
    call printf                            ; Llamar a printf
%endmacro

section .text

main:
    ALINEAR_PILA 16                        ; Configurar el marco de pila y reservar espacio

    MOSTRAR_INDICE                         ; Mostrar el carácter correspondiente

    DESALINEAR_PILA                        ; Restaurar el marco de pila

section .data
    secuenciaBinariaA db 0x1F, 0x03, 0x7A  ; Secuencia de bytes
    tabla db "ABCDEFGHIJKLMNÑOPQRSTUVWXYZabcdefghijklmnñopqrstuvwxyz", 0 ; Tabla de letras
    formato db "Carácter: %c", 10, 0       ; Formato para imprimir el carácter con salto de línea
