global main
extern printf

section .data
    binario db 11001001b          ; Valor binario de 8 bits (ejemplo)
    mensaje_hex db "Hexadecimal: %s", 10, 0

section .bss
    hexadecimal resb 3            ; Espacio para 2 caracteres hexadecimales + terminador nulo

section .text
main:
    ; Cargar el valor binario (8 bits) en AL
    mov al, [binario]

    ; Extraer el primer dígito hexadecimal (4 bits altos)
    mov ah, al                    ; Guardamos el valor original
    shr al, 4                     ; Desplazamos los 4 bits altos a la parte baja
    call obtener_caracter_hexadecimal
    mov [hexadecimal], al         ; Guardamos el primer dígito hexadecimal

    ; Extraer el segundo dígito hexadecimal (4 bits bajos)
    mov al, ah                    ; Recuperamos el valor original
    and al, 0xF                   ; Tomamos los 4 bits bajos
    call obtener_caracter_hexadecimal
    mov [hexadecimal + 1], al     ; Guardamos el segundo dígito hexadecimal

    ; Imprimir el resultado hexadecimal
    lea rdi, [mensaje_hex]
    lea rsi, [hexadecimal]
    xor eax, eax                  ; Limpiar EAX para llamar printf correctamente
    call printf

    ; Terminar el programa
    ret

; Función para obtener carácter hexadecimal de un valor (0-15)
obtener_caracter_hexadecimal:
    cmp al, 10
    jl es_numero
    add al, 'A' - 10              ; Si >= 10, convertir a letra (A-F)
    ret
es_numero:
    add al, '0'                   ; Si < 10, convertir a número (0-9)
    ret
