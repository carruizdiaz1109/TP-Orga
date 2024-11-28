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

section .data
    secuenciaBinariaA db 0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C
                       db 0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51
    largoSecuenciaA db 0x18     ; 24d
    formato db "Binario: %s", 10, 0 ; Formato para printf incluyendo el salto de línea

section .bss
    binario resb 9               ; Espacio para almacenar la representación binaria (8 bits + 1 para el null terminator)

section .text

%macro PASAR_BINARIO 0
    ; Inicializar registros
    lea rsi, [secuenciaBinariaA] ; Cargar dirección de secuenciaBinariaA
    movzx rcx, byte [largoSecuenciaA] ; Cargar el largo de la secuencia
    xor rbx, rbx                  ; Limpiar rbx para usarlo como índice

.next_byte:
    mov al, [rsi + rbx]           ; Cargar el byte actual
    call byte_to_binary           ; Convertir el byte a binario

    ; Imprimir el resultado
    lea rdi, [formato]            ; Cargar la dirección del formato
    lea rsi, [binario]            ; Cargar la dirección de binario
    xor rax, rax                  ; Limpiar rax para printf
    call printf                   ; Llamar a printf

    inc rbx                       ; Incrementar el índice
    cmp rbx, rcx                  ; Comparar con el largo de la secuencia
    jl .next_byte                 ; Si no hemos terminado, ir a la siguiente iteración

    ret
%endmacro

byte_to_binary:
    ; Guardar el estado de los registros en la pila
    push rbx                     ; Guardar rbx
    push rax                     ; Guardar rax

    ; Recibe el byte en AL y convierte a una representación binaria
    mov rcx, 8                    ; Contador para 8 bits
    lea rdi, [binario]            ; Cargar dirección para el resultado
    mov byte [rdi], 0             ; Inicializar el string
    mov rdx, 0                    ; Inicializar el índice en binario

.next_bit:
    shl al, 1                     ; Desplazar a la izquierda
    jc .set_one                   ; Si el bit más significativo es 1, ir a set_one
    mov byte [rdi + rdx], '0'     ; Colocar '0' en la posición actual
    jmp .next_char

.set_one:
    mov byte [rdi + rdx], '1'     ; Colocar '1' en la posición actual

.next_char:
    inc rdx                       ; Incrementar el índice
    loop .next_bit                ; Repetir para los 8 bits

    mov byte [rdi + rdx], 0       ; Null terminator para la cadena

    ; Restaurar el estado de los registros desde la pila
    pop rax                       ; Restaurar rax
    pop rbx                       ; Restaurar rbx
    ret                            ; Regresar a la llamada

main:
    ALINEAR_PILA 16              ; Configurar el marco de pila y reservar espacio

    PASAR_BINARIO                 ; Llamar a la macro para convertir y mostrar los bytes

    DESALINEAR_PILA              ; Restaurar el marco de pila
    
    ; Salir
    mov rax, 60                   ; syscall: exit
    xor rdi, rdi                  ; estado de salida
    syscall
