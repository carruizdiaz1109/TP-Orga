global main
extern imprimir_secuencia  ; Declarar la función de C para imprimir

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

; Macro para almacenar el valor de la tabla correspondiente a un índice
%macro GUARDAR_EN_SECUENCIA 3
    ; %1: Dirección base de la secuencia binaria
    ; %2: Desplazamiento del byte a procesar
    ; %3: Dirección de almacenamiento en secuenciaImprimible

    ; Cargar el byte correspondiente de la secuencia binaria
    movzx rax, byte [%1 + %2]              ; Cargar el valor en RAX y extenderlo

    ; Usar el valor como índice para acceder a la tabla
    lea rbx, [tabla]                       ; Cargar la dirección base de la tabla en RBX
    movzx rcx, byte [rbx + rax]            ; Obtener el carácter correspondiente

    ; Guardar el carácter en secuenciaImprimible
    mov byte [%3], cl                      ; Guardar el carácter en la posición correspondiente
%endmacro

section .text

main:
    ALINEAR_PILA 16                        ; Configurar el marco de pila y reservar espacio

    ; Guardar el carácter correspondiente al primer byte en secuenciaImprimible[0]
    GUARDAR_EN_SECUENCIA secuenciaBinariaA, 0, secuenciaImprimible

    ; Guardar el carácter correspondiente al segundo byte en secuenciaImprimible[1]
    GUARDAR_EN_SECUENCIA secuenciaBinariaA, 1, secuenciaImprimible + 1

    ; Agregar el terminador nulo a secuenciaImprimible[2]
    mov byte [secuenciaImprimible + 2], 0

    ; Llamar a la función `imprimir_secuencia` de C
    lea rdi, [secuenciaImprimible]         ; Pasar la dirección de secuenciaImprimible como argumento
    call imprimir_secuencia                ; Llamar a la función

    DESALINEAR_PILA                        ; Restaurar el marco de pila

section .data
    secuenciaBinariaA db 0x1F, 0x03        ; Secuencia de 2 bytes
    tabla db "ABCDEFGHIJKLMNÑOPQRSTUVWXYZabcdefghijklmnñopqrstuvwxyz", 0 ; Tabla de letras

section .bss
    secuenciaImprimible resb 3             ; Espacio para 2 caracteres y un terminador nulo
